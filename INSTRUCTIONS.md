Locomote Tycoon
===============

Play by API! Write an API to move your fleet, win airport dominance and take over the world.

## Game Play

The objective is to become the dominant airline at all airports controlled by your oponent. Gain dominance by flying your planes between airports

* Every Flight earns loyalty at the landing airport - once loyalty reaches 100% - the airport becomes yours
* Every Flight earns $100
* When you reach $300, a plane is purchased at your airport HQ (beginning airport)



### Test the mechanics - Click to play

To test the game mechanics, you can move planes manually between airports, and watch as loyalty and $ increase. Manual clicking gives you a way to figure out the rules of the game, and stage decision points for your API.



![LocoBot](/public/images/loco-bot.png)
## Bot
To test out your API, a simple client side bot has been written to control a team. Click the bot button for the relevant team to enable. Yes you can play bot vs bot


![LocoBot](/public/images/brain.png)
## Player APIs
On each turn, a player can move planes based upon instructions pulled from an external API. Enter the APIs endpoint into the relevant teams API textbox, then click on the brain.

At the start of each turn, for a team with an api enabled, the current gamestate is posted to the configured endpoint:

### Posted Data

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

