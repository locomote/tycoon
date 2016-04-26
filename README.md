Airline Tycoon
=======================

Expand your Airline to be the ultimate Tycoon!

## Install

```
npm install
bundle install
npm install -g gulp
```

## Develop

```
npm start
```
Includes
- Live reloading for both CSS and Javascript changes
- `.cjsx`: JSX in Coffeescript

`gulp build` to create minified versions for prod.



##Player APIs
On each turn, a player can move planes based upon instructions pulled from an external API.... Game state is posted to the api

i.e.

```
POST /some_endpoint HTTP/1.1
Host: some_host:some_port
Connection: keep-alive
Content-Length: 1896
Accept: application/json, text/javascript, */*; q=0.01
Content-Type: application/json; charset=UTF-8
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.8


{
  "players": [
    {
      "name": "Blue",
      "color": "#9fc5e8",
      "money": 0
    }
    ...
  ],
  "loyalty": [
    {
      "location": "NYC",
      "amount": 0,
      "owner": "Blue"
    }
    ...
  ],
  "airports": [
    {
      "key": "NYC",
      "name": "NYC",
      "x": 330,
      "y": 300
    }
    ...
  ],
  "routes": [
    {
      "key": "NYC->LHR",
      "name": "NYC->LHR",
      "start": "NYC",
      "end": "LHR"
    },
    {
      "key": "LHR->NYC",
      "name": "LHR->NYC",
      "start": "LHR",
      "end": "NYC"
    }
    ...
  ],
  "planes": [
    {
      "name": "Plane1",
      "flights_flown": 0,
      "location": "MEL",
      "owner": "Blue"
    },
    {
      "name": "Plane6",
      "flights_flown": 0,
      "location": "NYC",
      "owner": "Pink"
    }
    ...
  ]
}


An API is expected to return movements for their Player planes.... i.e. IF an API
is controlling the "Pink" team
```
[
  {
    "name": "Plane6",
    "location": "NYC->LHR"
  }
]
```


Incredibly simple player-api `https://github.com/benkitzelman/tycoon-sample-api`
Platform forked from https://github.com/KyleAMathews/coffee-react-quickstart
