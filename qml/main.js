function httpRequest(requestType, url, callback, params) {
    var request = new XMLHttpRequest();

    request.onreadystatechange = function() {
        if (request.readyState === 4) {
            //console.log("STATUS:", request.status)
            //console.log("RESPONSE:", request.responseText)
            callback(request.status, request.responseText);
        }
    }

    request.open(requestType, url, true);

    request.setRequestHeader("Accept", "text/html")
    //request.setRequestHeader("Accept", "application/json");
    request.setRequestHeader("User-Agent", "Mozilla/5.0 (X11; Linux x86_64) Gecko/20100101 Firefox/115.0");
    //request.setRequestHeader("Referer", "https://yewtu.be/");
    //request.setRequestHeader("Origin", "https://yewtu.be");

    request.send(params);
}

function httpRequestPT(method, url, callback) {
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

function fetchChannelFromVideo(videoId, callback) {
    var url = getInvInstance()+"/search?q=" + videoId + "&type=video";
    var request = new XMLHttpRequest();

    request.onreadystatechange = function() {
        if (request.readyState === 4) {

            if (request.status !== 200) {
                console.log("HTTP ERROR", request.status);
                callback(null);
                return;
            }

            var html = request.responseText;

            // find first channel link
            var matchId = html.match(/href="\/channel\/([^"]+)"/);
            var matchName = html.match(/<p class="channel-name"[^>]*>([\s\S]*?)<\/p>/);

            if (!matchId || !matchName) {
                console.log("Channel not found in search results");
                callback(null);
                return;
            }

            var channelId = matchId[1].toString();

            var channelName = matchName[1]
            .replace(/<[^>]+>/g, "")
            .replace(/&amp;/g, "&")
            .replace(/&nbsp;/g, " ")
            .replace(/\n/g, "")
            .trim();

            callback({
                         channelId: channelId,
                         channelName: channelName
                     });
        }
    };

    request.open("GET", url, true);

    request.setRequestHeader("Accept", "text/html");
    request.setRequestHeader("User-Agent", "Mozilla/5.0 (X11; Linux x86_64)");

    request.send();
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

function getInvInstance() {
    return "https://inv.nadeko.net"
}

function getInvInstanceImg() {
    return "https://invidious.nerdvpn.de"
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
