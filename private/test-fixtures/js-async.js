async function fetchData(url) {
  try {
    const kind = "json";
    const res = await fetch(url);
    return await res.json();
  } catch (err) {
    console.error(err);
    return null;
  }
}
