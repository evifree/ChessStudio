function myFunction() {
    document.getElementById("selected").style.color = "#CD3333";
}

function myFunction2() {
    var x = document.getElementsByClassName("whiteMove");
    //x[2].innerHTML = "loffa";
    x[3].style.color = "#CD3333";
    x[10].style.color = "#CD3333";
}

function myFunction3(n) {
    var x = document.getElementsByClassName("move");
    var oldColor = x[n].style.color;
    for (i=0; i<x.length; i++) {
        if (i == n) {
            x[i].style.color = "#CD3333";
        }
        else {
            x[i].style.color = oldColor;
        }
    }
}

function myFunction9(n) {
    var x = document.getElementsByTagName("a");
    var oldColor = x[n].style.color;
    for (i=0; i<x.length; i++) {
        if (i == n) {
            x[i].style.color = "#CD3333";
        }
        else {
            x[i].style.color = oldColor;
        }
    }
}

function cambiaColoreTesto(c) {
    //alert(c);
    var x = document.getElementsByClassName("move");
    for (i=0; i<x.length; i++) {
        //x[i].style.color = "#CD3333";
        x[i].style.color = c;
    }
    var y = document.getElementsByClassName("result");
    for (i=0; i<y.length; i++) {
        //x[i].style.color = "#CD3333";
        y[i].style.color = c;
    }
}

function myFunction5(colore) {
    document.getElementsByTagName("body")[0].style.backgroundColor = colore;
}

function myFunction4(n) {
    var x = document.getElementsByClassName("Move");
    var mossa = x[n].innerHTML;
    //alert(mossa);
}

function getInterlinea() {
    alert(document.getElementById("game-div").style.letterSpacing);
}