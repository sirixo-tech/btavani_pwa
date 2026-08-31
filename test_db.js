const { Client } = require('pg');
const client = new Client({ connectionString: process.env.DATABASE_URL });
client.connect().then(() => {
  client.query("SELECT id, section, title FROM cms_entries WHERE section = 'app_setting'").then(res => {
    console.log(res.rows);
    client.end();
  });
});
