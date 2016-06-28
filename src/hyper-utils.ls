level = require \level-browserify
sodium = require \chloride/browser


export export-db = (db,cb) !-> data = []; db.create-read-stream!on(\data ,(r)-> data.push r).on \end , -> cb data if cb
export import-db = (db,cb) !-> data = []; db.create-read-stream!on(\data ,(r)-> data.push r).on \end , -> cb data if cb
export create-db = -> level it, valueEncoding: \json 

export write = (db, key, value, cb)-> if db then db.put key, value, (r,e)-> cb r,e if cb
export write-stream = (db, key, value, cb)-> db.wr key , value, (r,e)-> cb(r,e) if cb
export read = (db, key, cb)-> db.get key, (r,e)-> cb r,e if cb
export read-stream = (db, key, cb)-> db.get key, (r,e)-> cb r,e if cb


export to-hex = -> it.toString \hex
export to-buff = -> Buffer it, \hex


export sign = (message) ->
    secretKey = Buffer(_keys.secretKey, \hex)
    msg = new Buffer(message)
    sig = sodium.crypto_sign_detached(msg, secretKey)
    sig.toString \hex

export verify = (sig, pub, message) -> sodium.crypto_sign_verify_detached <<< to-buff

    

export create-account = -> sodium.crypto_sign_keypair!


# export key-to-hex = -> [for own let key,val of it when true val=to-hex val]

export create-crypto-box = -> sodium.crypto_box_keypair!


# export init-collections: -> for own key, val of it window[key] = _.extend(collections[key], new COLLECTION_BASE)
            
    
