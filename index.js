const express = require('express');
const hbs = require('hbs');
const wax = require('wax-on');
const mysql = require('mysql2/promise');
require('dotenv').config();

const helpers = require('handlebars-helpers')({
    'handlebars': hbs.handlebars
})

const app = express();

// setup express
app.set('view engine', 'hbs')
app.use(express.urlencoded({
    extended: false
}))

wax.on(hbs.handlebars);
wax.setLayoutPath('./views/layouts')

async function main() {
    const connection = await mysql.createConnection({
        'host': process.env.DB_HOST, // local host means the db server is on the IP aaddres as the express server
        'user': process.env.DB_USER,
        'database': process.env.DB_DATABASE,
        'password': process.env.DB_PASSWORD
    })

    // let query = "select * from actor";
    // results will be an array, the first element
    // (i.e index 0) will contain all the rows from the queue
    // let results = await connection.execute(query);
    // console.log(results[0])

    app.get('/actors', async (req, res) => {
        let [actors] = await connection.execute("select * from actor")
        // let results = await connection.execute("select * from actors")
        // let results
        res.render('actors', {
            'actors': actors
        })
    })

    app.get('/actors/create', (req, res) => {
        res.render('create_actor')
    })

    app.post('/actors/create', async (req, res) => {
        let {
            first_name,
            last_name
        } = req.body;
        // using prepared statement to avoid sql injection
        let query = `INSERT INTO actor
        (first_name, last_name) values (?, ?)`
        await connection.execute(query, [first_name, last_name]);
        res.redirect("/actors");
    })

    app.get('/actors/:actor_id/update', async (req, res) => {
        let actorId = req.params.actor_id;

        // Select will always return an array of rows
        // Since we're selecting by actor_id, the PK, there should only be at most one row
        let [actors] = await connection.execute('select * from actor where actor_id = ?', [actorId]);
        let actor = actors[0];
        res.render('edit_actor', {
            'actor': actor
        })
    })

    app.post('/actors/:actor_id/update', async (req, res) => {
        let firstName = req.body.first_name;
        let lastName = req.body.last_name;

        let actorId = req.params.actor_id;
        let query = `UPDATE actor SET first_name=?, last_name=? WHERE actor_id = ?`;
        await connection.execute(query, [firstName, lastName, actorId]);
        res.redirect('/actors');
    })

    app.get('/actors/:actor_id/delete', async (req, res) => {
        let [actors] = await connection.execute(`SELECT * from actor WHERE actor_id = ?;`, [req.params.actor_id]);
        let actor = actors[0];
        res.render('delete_actor', {
            'actor': actor
        })
    })

    app.post('/actors/:actor_id/delete', async (req, res) => {

        let [film_actor] = await connection.execute(`select * from film_actor where actor_id = ?`, [req.params.actor_id]);
        if (film_actor.length > 0) {
            res.send("Sorry, we cannot delete the actor because they're in some films")
        }

        await connection.execute(`delete from actor where actor_id = ?`, [req.params.actor_id]);
        res.redirect('/actors')
    })

    app.get('/films', async (req, res) => {
        // always true query AKA a query that returns all row
        let query = `SELECT film.*, language.name as "language_name" from film join language
        ON film.language_id = language.language_id WHERE 1`;

        let bindings = [];

        if (req.query.title) {
            query += " AND TITLE LIKE ?";
            bindings.push(`%` + req.query.title + `%`);
        }

        if (req.query.year) {
            query += `AND release_year = ?`;
            bindings.push(req.query.year)
        }

        let [films] = await connection.execute(query, bindings);
        res.render('films', {
            'films': films
        })
    })

}

main();

app.listen(3000, function () {
    console.log("server has started")
})