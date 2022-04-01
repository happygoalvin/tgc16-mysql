const express = require('express');
const hbs = require('hbs');
const wax = require('wax-on');
require('dotenv').config();

// make sure to use the version of mysql2 that supports promises
const mysql = require('mysql2/promise');

const helpers = require('handlebars-helpers')({
    'handlebars': hbs.handlebars
})

const app = express();

// setup express
app.set('view engine', 'hbs');
app.use(express.urlencoded({
    'extended': false
}))

wax.on(hbs.handlebars);
wax.setLayoutPath('./views/layouts');

async function main() {
    const connection = await mysql.createConnection({
        'host': process.env.DB_HOST, // localhost means the db server is on the IP address as the express server
        'user': process.env.DB_USER,
        'database': process.env.DB_DATABASE,
        'password': process.env.DB_PASSWORD
    })

    // let query = "select * from actor";
    // // results will be an array, the first element
    // // (i.e index 0) will contain all the rows from the query
    // let results = await connection.execute(query);
    // console.log(results[0]);

    app.get('/actors', async function (req, res) {
        let [actors] = await connection.execute("select * from actor");
        // let results = await connection.execute("select * from actor");
        // let actors = results[0];
        res.render('actor', {
            'actors': actors
        })
    })

    app.get('/actors/create', function (req, res) {
        res.render('create_actor')
    })

    app.post('/actors/create', async function (req, res) {
        let firstName = req.body.first_name;
        let lastName = req.body.last_name;
        // using prepared statements to avoid sql injection
        let query = `INSERT INTO actor (first_name, last_name) values (?, ?)`
        await connection.execute(query, [firstName, lastName]);
        res.send("Created");
    })

    app.get('/actors/:actor_id/update', async function (req, res) {
        let actorId = req.params.actor_id;

        // select will always return an array of rows
        // since we're selecting by actor_id, the PK, there should only be at  most one row
        let [actors] = await connection.execute('select * from actor where actor_id = ?', [actorId]);
        let actor = actors[0];
        res.render('edit_actor', {
            'actor': actor
        })
    })

    app.post('/actors/:actor_id/update', async function (req, res) {
        let firstName = req.body.first_name;
        let lastName = req.body.last_name;

        let actorId = req.params.actor_id;
        let query = `UPDATE actor SET first_name=?, last_name=? WHERE actor_id = ?`;
        await connection.execute(query, [firstName, lastName, actorId]);
        res.redirect('/actors');
    })

    app.get('/actors/:actor_id/delete', async function (req, res) {
        let [actors] = await connection.execute(`SELECT * from actor where actor_id = ?`, [req.params.actor_id]);
        let actor = actors[0];
        res.render('delete_actor', {
            'actor': actor
        })
    })

    app.post('/actors/:actor_id/delete', async function (req, res) {

        let [film_actors] = await connection.execute("select * from film_actor where actor_id = ?", [req.params.actor_id]);
        if (film_actors.length > 0) {
            res.send("Sorry, we cannot delete the actor because they're in some films");
        }

        await connection.execute(`delete from actor where actor_id = ?`, [req.params.actor_id]);
        res.redirect('/actors');
    })

    app.get('/films', async function (req, res) {
        // always true query (aka a query that returns all rows)
        let query = `SELECT film.*, language.name as "language_name" from film join language 
                        ON film.language_id = language.language_id             
                        WHERE 1`;

        let bindings = [];

        if (req.query.title) {
            query += " AND title LIKE ?";
            bindings.push('%' + req.query.title + '%');
        }

        if (req.query.year) {
            query += " AND  release_year = ?";
            bindings.push(req.query.year)
        }

        let [films] = await connection.execute(query, bindings);
        res.render('films', {
            'films': films
        })

    })

    app.get('/films/:actor_id/actors', async function (req, res) {
        let query = `SELECT actor.* from film            
                     JOIN film_actor ON film_actor.film_id = film.film_id
                     JOIN actor ON film_actor.actor_id = actor.actor_id
                     WHERE film.film_id = ?
                     `
        let [actors] = await connection.execute(query, [req.params.actor_id]);
        res.render('film_actors', {
            'actors': actors
        })
    })

    app.get('/films/create', async function (req, res) {
        let [languages] = await connection.execute("SELECT * from language");
        let [actors] = await connection.execute("SELECT * from actor");
        res.render('create_film', {
            languages,
            actors
        })
    })

    app.post('/films/create', async function (req, res) {
        let query = `INSERT INTO film (title, description,release_year,language_id) VALUES (?,?,?,?)`;
        console.log(req.body);
        let [results] = await connection.execute(query, [
            req.body.title,
            req.body.description,
            req.body.release_year,
            req.body.language_id
        ]);
        let newFilmID = results.insertId; // insertId will store the id of the newly inserted row

        for (let actor_id of req.body.actors) {
            await connection.execute(
                "INSERT INTO film_actor (actor_id, film_id) values (?,?)",
                [actor_id, newFilmID]
            )
        }
        res.redirect('/films')
    })

    app.get('/films/:film_id/edit', async function (req, res) {
        let [languages] = await connection.execute("SELECT * from language");
        let [actor_ids] = await connection.execute("SELECT actor_id from film_actor where film_id =?", [req.params.film_id])
        let [actors] = await connection.execute("SELECT * from actor");
        let [film] = await connection.execute(
            "select * from film where film_id =?", [req.params.film_id]
        )

        actor_ids = actor_ids.map(a => a.actor_id);


        res.render('edit_film', {
            'film': film[0],
            'languages': languages,
            'actor_ids': actor_ids,
            'actors': actors
        })
    })

    app.post('/films/:film_id/edit', async function (req, res) {
        let query = `UPDATE film SET title=?,description=?,release_year=?,language_id=?
                      WHERE film_id = ?`;
        let bindings = [
            req.body.title,
            req.body.description,
            req.body.release_year,
            req.body.language_id,
            req.params.film_id
        ]

        await connection.execute(query, bindings);

        // update the actors in the films

        // 1. delete all the actors from the films
        await connection.execute("DELETE FROM film_actor WHERE film_id = ?", [req.params.film_id]);

        // 2. re-add all the actors selected in the form
        for (let actor_id of req.body.actors) {
            await connection.execute(
                "INSERT INTO film_actor (actor_id, film_id) values (?,?)",
                [actor_id, req.params.film_id]
            )
        }
        res.redirect('/films')
    })
}

main();

app.listen(3000, function () {
    console.log("Server has started")
})