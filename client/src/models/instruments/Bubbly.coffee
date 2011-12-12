###
#   @file       Bubbly.coffee
#
#   @author     Colin Sullivan <colinsul [at] gmail.com>
#
#               Copyright (c) 2011 Colin Sullivan
#               Licensed under the MIT license.
###


###
#   @class  Short bubbly percussive sound.
###
class hwfinal.models.instruments.Bubbly extends hwfinal.models.instruments.PitchedInstrument
    
    namespace: "hwfinal.models.instruments.Bubbly"

    initialize: (attributes) ->
        @maxPitchIndex = 14
        super