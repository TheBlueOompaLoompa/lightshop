extends Node

class Schema:
    var name: String
    var tempo: float = 120.0
    var time: float = 0.0
    var offset: float = 0.0
    var song_file: String

    const INFO = {'name': { 'data_type': 'text', 'primary_key': true }, 'tempo': { 'data_type': 'real', 'default': 120.0, 'not_null': true }, 'time': { 'data_type': 'real', 'default': 0.0, 'not_null': true }, 'offset': { 'data_type': 'real', 'default': 0.0, 'not_null': true }, 'song_file': { 'data_type': 'text', 'not_null': true } }
