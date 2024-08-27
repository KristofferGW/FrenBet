// This example shows how to make call an API using a secret
// https://coinmarketcap.com/api/documentation/v1/

// Arguments can be provided when a request is initated on-chain and used in the request source code as shown below
const matchId = args[0];

if (!secrets.apiKey) {
  throw Error(
    "FOOTBALL_DATA_ORG_API_KEY environment variable not set for Football-Data.org API"
  );
}

// build HTTP request object

const footballDataOrgRequest = Functions.makeHttpRequest({
  url: `http://api.football-data.org/v4/matches/${matchId}`,
  // Get a free API key from https://coinmarketcap.com/api/
  headers: {
    "Content-Type": "application/json",
    "X-Auth-Token": secrets.apiKey,
  },
//   params: {
//     matchId: matchId
//   },
});

// Make the HTTP request
const footballDataOrgResponse = await footballDataOrgRequest;

if (footballDataOrgResponse.error) {
  throw new Error("Football-Data.org Error");
}

//fetch match result
const matchResult = footballDataOrgResponse.data["score"]["winner"];
// const matchResult = footballDataOrgResponse.data.score.winner;

// fetch the price
// const price =
//   coinMarketCapResponse.data.data[coinMarketCapCoinId]["quote"][currencyCode][
//     "price"
//   ];

console.log(`Winner of the game was ${matchResult}`);

console.log("Functions.encodeString: ", Functions.encodeString(matchResult));

// price * 100 to move by 2 decimals (Solidity doesn't support decimals)
// Math.round() to round to the nearest integer
// Functions.encodeUint256() helper function to encode the result from uint256 to bytes
return Functions.encodeString(matchResult);