(async () => {
  const { Client } = await import("pg");
  const client = new Client({ connectionString: process.env.DATABASE_URL });

  await client.connect();
  const result = await client.query(
    "SELECT id, section, title FROM cms_entries WHERE section = 'app_setting'",
  );

  console.log(result.rows);
  await client.end();
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
