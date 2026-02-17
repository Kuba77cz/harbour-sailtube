function httpRequest(requestType, url, callback, params) {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        if (request.readyState === 4) {
            if (request.status === 200) {
//                console.log("Get response:", request.responseText);
                callback(request.responseText);
            } else {
                callback("error");
            }
        }
    }
    request.open(requestType, url);
//    request.setRequestHeader('Accept-Encoding', 'gzip, deflate, bzip2, compress');
//    if(requestType === "GET") {
//        request.setRequestHeader('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0');
//        request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
//    } else {
//        request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
//    }
    console.log("send url", url);
    request.send(params);
}

function httpRequest1(method, url) {
    return new Promise(function(resolve, reject) {
        var xhr = new XMLHttpRequest();
        xhr.open(method, url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    resolve(xhr.responseText);
                } else {
                    reject(xhr.statusText);
                }
            }
        };
        xhr.send();
    });
}


function httpRequest2(method, url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true); // `true` makes the request asynchronous
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                var result = callback(xhr.responseText);
                console.log(result);
            } else {
                console.log("Error: " + xhr.status);
            }
        }
    };
    xhr.send();
}

function search(query,type) { //iteroni.com
    return url = getInvInstance()+"/api/v1/search?q="+query+"&region=CZ&type="+type
}

function getDatabase() {
    return LocalStorage.openDatabaseSync("Sailtube", "1.0", "StorageDatabase", 10000000);
}

function addItem(videoid,title,service) {
    var db = getDatabase();
    var res = ""
    var rs = ""

    db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS history(videoid TEXT, title TEXT, service INTEGER)');
            rs = tx.executeSql('INSERT INTO history VALUES(?,?,?)', [videoid,title,service]);

        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log("Saved to database - "+videoid+" "+title+" "+service);
        } else {
            tx.executeSql('CREATE TABLE IF NOT EXISTS history(videoid TEXT, title TEXT, service INTEGER)');
            res = "Error";
            //console.log("Error of saving");
        }
    });
    return res;
}

function deleteItem(id) {
    var db = getDatabase();
    var res = ""
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM history WHERE rowid=?', [id]);

        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
    });
    return res;
}

function deleteItemVI(id) {
    var db = getDatabase();
    var res = ""
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS history(videoid TEXT, title TEXT, service INTEGER)');
        var rs = tx.executeSql('DELETE FROM history WHERE videoid=?', [id]);

        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
    });
    return res;
}

function getAllItems() {
    var db = getDatabase();
    var stat="";
    var text;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT rowid, videoid, title, service FROM history ORDER BY rowid DESC');
        for(var i = 0; i < rs.rows.length; ++i) {
            stat = { "rowid": rs.rows.item(i).rowid, "videoid": 
rs.rows.item(i).videoid, "title": rs.rows.item(i).title, "service": rs.rows.item(i).service}
            myJSModel.append(stat)
        }
    })
    return stat
}

function addFavItem(videoid,title,service) {
    var db = getDatabase();
    var res = ""
    var rs = ""

    db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS fav(videoid TEXT, title TEXT, service INTEGER)')
            rs = tx.executeSql('INSERT INTO fav VALUES(?,?,?)', [videoid,title,service]);

        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log("Saved to database - "+videoid+" "+title+" "+service);
        } else {
            res = "Error";
            //console.log("Error of saving");
        }
    });
    return res;
}

function deleteFavItem(id) {
    var db = getDatabase();
    var res = ""
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM fav WHERE rowid=?', [id]);

        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
    });
    return res;
}

function getAllFavItems() {
    var db = getDatabase();
    var stat="";
    var text;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT rowid, videoid, title, service FROM fav ORDER BY rowid DESC')
        for(var i = 0; i < rs.rows.length; ++i) {
            stat = { "rowid": rs.rows.item(i).rowid, "videoid":
rs.rows.item(i).videoid, "title": rs.rows.item(i).title, "service": rs.rows.item(i).service}
            myJSModel.append(stat)
        }
    })
    return stat
}


function pData(data) {
    var jsonObject = JSON.parse(data);
    var url = jsonObject[0][1].uri
    console.log(url);
    return url;
}

/*function getInstance2() {
    var url = "https://api.invidious.io/instances.json?sort_by=type,health"
    var firstItemUrl = httpRequest("GET", url, pData)
    //var jsonObject = JSON.parse(jsonData)
    console.log(firstItemUrl.toString());
    return firstItemUrl;
}

function getInstance(callback) {
    var url = "https://api.invidious.io/instances.json?sort_by=type,health";
    httpRequest2("GET", url, function(response) {
        var firstItemUrl = pData(response);
        if (callback) {
            callback(firstItemUrl);
        } else {
            console.error("Callback is not defined");
        }
    });
}*/

function getInvInstance() {
//	return "https://invidious.nerdvpn.de"
//	return "https://invidious.f5.si"
//	return "https://invidious.privacyredirect.com"
//	return "https://nyc1.iv.ggtyler.dev"
//	return "https://inv.nadeko.net"
//	return "https://invidious.privacyredirect.com"
//	return "https://invidious.perennialte.ch"
    return "https://invidious.reallyaweso.me"
}

function getItemPosition(id) {
    var db = LocalStorage.openDatabaseSync("PlayerDB", "1.0", "Player DB", 100000)
    var pos = 0

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT position FROM videos WHERE id=?', [id])
        if (rs.rows.length > 0)
            pos = rs.rows.item(0).position
    })

    return pos
}

function updateItemPosition(id, position) {
    var db = LocalStorage.openDatabaseSync("PlayerDB", "1.0", "Player DB", 100000)

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS videos(id TEXT PRIMARY KEY, position INTEGER)');

        var res = tx.executeSql('UPDATE videos SET position=? WHERE id=?', [position, id])

        if (res.rowsAffected === 0) {
            tx.executeSql(
                'INSERT INTO videos (id, position) VALUES (?, ?)',
                [id, position]
            )
        }

    })
}

function formatSeconds(seconds) {
    var h = Math.floor(seconds / 3600)
    var m = Math.floor((seconds % 3600) / 60)
    var s = seconds % 60

    // when you want h:mm:ss
    var hh = h > 0 ? h + ":" : ""
    var mm = (h > 0 && m < 10 ? "0" : "") + m
    var ss = (s < 10 ? "0" : "") + s

    return hh + mm + ":" + ss
}

function processData(data, imageElement) {
    var json = data;
    var obj = JSON.parse(json);
    //var ="";
    if (obj.thumbnailPath.length > 0) {
        imageurl = "https://peertube.arch-linux.cz" + obj.thumbnailPath;
        imageElement.source = imageurl;
        return imageurl;
    }
}
