# We could integrate a web call to an API by extending this class
# - i.e. send a post to an applicant's API with a JSON doc defining
# game state (i.e. locations, planes, player assets) and their api
# would decide what to do next and send back JSON movement cmds...
class Brain

  # why cb?... when we extend Brain to hook up an API - it will allow us to wait
  # for the http response... this is just the interface
  nextMove: (cb = ->) -> cb()




module.exports = Brain