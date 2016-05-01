Locomote Tycoon
===============

Play by API! Write a JSON Web Service to move your fleet, win airport dominance and take over the world.

## Game Rules

The objective is to become the dominant airline at all airports controlled by your oponent. Gain dominance by flying your planes between airports

* Every Flight earns loyalty at the landing airport - once loyalty reaches 100% - the airport becomes yours
* Every Flight earns you money! How much depends on the Route chosen. Route values can be found [here](/src/data/route.coffee)
* When you reach $500, a plane is purchased at your airport HQ (beginning airport)


## First Steps

![LocoBot](/public/images/loco-bot.png)
Click the Robot Button for both teams, and see the game mechanics at play. **Your goal is to write an JSON Web Service to replace the Robot on one of the teams.**

![LocoBot](/public/images/brain.png)
To use your API - enter the API's endpoint into the relevant teams API textbox (i.e. `http://myhost.com/my_endpoint`), then click on the brain.

At the start of each turn, for a team with an api enabled, the current gamestate is posted to the configured endpoint:

### Posted Data

```
POST /my_endpoint HTTP/1.1
Host: some_host:some_port
Connection: keep-alive
Accept: application/json, text/javascript, */*; q=0.01
Content-Type: application/json; charset=UTF-8
Accept-Encoding: gzip, deflate


{
  "currentPlayer": "Blue",
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
      "end": "LHR",
      "flightValue": 200
    },
    {
      "key": "LHR->NYC",
      "name": "LHR->NYC",
      "start": "LHR",
      "end": "NYC",
      "flightValue": 50
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
```


### Expected Response Format

An API is expected to return movements for their Player planes.... i.e. IF an API
is controlling the "Blue" team

```
[
  {
    "name": "Plane1",
    "location": "MEL->DUB"
  }
  ...
]
```

### Test the mechanics - Click to play

To test the game mechanics, you can move planes manually between airports, and watch as loyalty and $ increase. Manual clicking gives you a way to figure out the rules of the game, and stage decision points for your API.

