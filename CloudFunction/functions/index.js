const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const database = admin.database();

function getNow() {
    var today = new Date();
    var dd = String(today.getDate());
    var mm = String(today.getMonth() + 1);
    var yyyy = String(today.getFullYear());
    var now = dd + '/' + mm + '/' + yyyy;
    return now;
}

function getReserve() {
    var today = new Date();
    var dd = String(today.getDate());
    if (dd.length == 1) dd = '0' + dd;
    var mm = String(today.getMonth() + 1);
    if (mm.length == 1) mm = '0' + mm;
    var yyyy = String(today.getFullYear());
    var now = yyyy + '-' + mm + '-' + dd;
    return now;
}

exports.saveCrop = functions.database.ref("/data/{id}").onCreate(async (snap, context) => {
    var data = database.ref("data");
    var ph = 0;
    var tds = 0;
    var temperature = 0;
    var count = 0;
    var now = getNow();

    data.once('value', (snap) => {

        snap.forEach((childSnap) => {
            if (String(childSnap.val().day) == now) {
                count++;
                ph += Number(childSnap.val().ph);
                tds += Number(childSnap.val().tds);
                temperature += Number(childSnap.val().temperature);
            }
        });

        var reserve = getReserve().split("/").join("-");
        return database.ref(`crop/${reserve}`).set({
            ph: ph / count,
            tds: tds / count,
            temperature: temperature / count,
        });

    });

}); //Complete


