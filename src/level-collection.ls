
class LevelCollection
    db:null
    _key = null
    get-entrys: (cb)-> read-db @db, _key, cb
    (name, options = {})->
        _key = "_collection_#{name}_"
        @db = options.db or STATE_DB
    find:(query, cb)-> @get-entrys (entrys)-> 
    get:(_id, cb)-> @db.get _key+_id, (e,r)~> cb(@transform?(r) or r,e)
    create:(obj, cb)->
        data = obj
        _id = uuid!; @db.put _key+_id, data, (e)-> cb _id,e if cb



module.exports = LevelCollection