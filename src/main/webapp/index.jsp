<!DOCTYPE html>
<html dir="ltr" lang="zh-CN">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width"/>
    <title></title>
    <style>body {
        background: #FFF;
        margin: 0;
    }

    canvas {
        cursor: crosshair;
        display: block;
    }
    </style>
</head>
<body>
<div style="text-align:center;clear:both"></div>
<canvas id="canvas">Canvas is not supported.</canvas>

<script src="resources/sockjs-0.3.4.js"></script>
<script src="resources/stomp.js"></script>

<script>
    function connect() {
        var socket = new SockJS('/Spring4WebSocket/add');
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function(frame) {
            console.log('Connected: ' + frame);
            stompClient.subscribe('/topic/showResult', function(calResult){
                showResult(JSON.parse(calResult.body).result);
            });
        });
    }


    function showResult(message) {

        var obj = JSON.parse(message);
                if (obj) {
                    mx = cw * (obj['x'] / 100);
                    my = ch * (obj['y'] / 100);
                    mousedown = true;

                    fireworks.push(new Firework(mx, my, mx, my));
                }
        console.log('showResult: ' + message);
    }

    window.requestAnimFrame = (function () {
    return window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        function (callback) {
            window.setTimeout(callback, 1000 / 60);
        };
})();

var canvas = document.getElementById('canvas'),
    ctx = canvas.getContext('2d'),

    cw = window.innerWidth,
    ch = window.innerHeight,

    fireworks = [],

    particles = [],

    hue = 120,

    limiterTotal = 5,
    limiterTick = 0,

    timerTotal = 80,
    timerTick = 0,
    mousedown = false,
    mx,
    my;

canvas.width = cw;
canvas.height = ch;

function random(min, max) {
    return Math.random() * ( max - min ) + min;
}

function calculateDistance(p1x, p1y, p2x, p2y) {
    var xDistance = p1x - p2x,
        yDistance = p1y - p2y;
    return Math.sqrt(Math.pow(xDistance, 2) + Math.pow(yDistance, 2));
}

function Firework(sx, sy, tx, ty) {

    this.x = sx;
    this.y = sy;

    this.sx = sx;
    this.sy = sy;

    this.tx = tx;
    this.ty = ty;

    this.distanceToTarget = calculateDistance(sx, sy, tx, ty);
    this.distanceTraveled = 0;
    this.coordinates = [];
    this.coordinateCount = 3;
    while (this.coordinateCount--) {
        this.coordinates.push([this.x, this.y]);
    }
    this.angle = Math.atan2(ty - sy, tx - sx);
    this.speed = 2000;
    this.acceleration = 1.05;
    this.brightness = random(50, 70);
    this.targetRadius = 1;
}


Firework.prototype.update = function (index) {

    this.coordinates.pop();
    this.coordinates.unshift([this.x, this.y]);

    if (this.targetRadius < 8) {
        this.targetRadius += 0.3;
    } else {
        this.targetRadius = 1;
    }

    this.speed *= this.acceleration;

    var vx = Math.cos(this.angle) * this.speed,
        vy = Math.sin(this.angle) * this.speed;

    this.distanceTraveled = calculateDistance(this.sx, this.sy, this.x + vx, this.y + vy);

    if (this.distanceTraveled >= this.distanceToTarget) {
        createParticles(this.tx, this.ty);
        fireworks.splice(index, 1);
    } else {
        this.x += vx;
        this.y += vy;
    }
}


Firework.prototype.draw = function () {
    ctx.beginPath();
    ctx.moveTo(this.coordinates[this.coordinates.length - 1][0], this.coordinates[this.coordinates.length - 1][1]);
    ctx.lineTo(this.x, this.y);
    ctx.strokeStyle = 'hsl(' + hue + ', 100%, ' + this.brightness + '%)';
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(this.tx, this.ty, this.targetRadius, 0, Math.PI * 2);
    ctx.stroke();
}


function Particle(x, y) {
    this.x = x;
    this.y = y;
    this.coordinates = [];
    this.coordinateCount = 5;
    while (this.coordinateCount--) {
        this.coordinates.push([this.x, this.y]);
    }
    this.angle = random(0, Math.PI * 2);
    this.speed = random(1, 10);
    this.friction = 0.95;
    this.gravity = 1;
    this.hue = random(hue - 20, hue + 20);
    this.brightness = random(50, 80);
    this.alpha = 1;
    this.decay = random(0.015, 0.03);
}


Particle.prototype.update = function (index) {
    this.coordinates.pop();
    this.coordinates.unshift([this.x, this.y]);
    this.speed *= this.friction;
    this.x += Math.cos(this.angle) * this.speed;
    this.y += Math.sin(this.angle) * this.speed + this.gravity;
    this.alpha -= this.decay;


    if (this.alpha <= this.decay) {
        particles.splice(index, 1);
    }
}

Particle.prototype.draw = function () {
    ctx.beginPath();
    ctx.moveTo(this.coordinates[this.coordinates.length - 1][0], this.coordinates[this.coordinates.length - 1][1]);
    ctx.lineTo(this.x, this.y);
    ctx.strokeStyle = 'hsla(' + this.hue + ', 100%, ' + this.brightness + '%, ' + this.alpha + ')';
    ctx.stroke();
}


function createParticles(x, y) {

    var particleCount = 60;
    while (particleCount--) {
        particles.push(new Particle(x, y));
    }
}

// main demo loop
function loop() {
    requestAnimFrame(loop);


    hue += 0.5;

    ctx.globalCompositeOperation = 'destination-out';

    ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
    ctx.fillRect(0, 0, cw, ch);

    ctx.globalCompositeOperation = 'lighter';


    var i = fireworks.length;
    while (i--) {
        fireworks[i].draw();
        fireworks[i].update(i);
    }

    var i = particles.length;
    while (i--) {
        particles[i].draw();
        particles[i].update(i);
    }

//    if (limiterTick >= limiterTotal) {
//        if (mousedown) {
//            fireworks.push(new Firework(mx, my, mx, my));
//            limiterTick = 0;
//        }
//    } else {
//        limiterTick++;
//    }
}

//function showJson() {
//    var test;
//    if (window.XMLHttpRequest) {
//        test = new XMLHttpRequest();
//    } else if (window.ActiveXObject) {
//        test = new window.ActiveXObject();
//    } else {
//        alert("请升级至最新版本的浏览器");
//    }
//    if (test != null) {
//        test.open("GET", "http://mca.ayona333.com/index.php?m=index&a=ppt", true);
//        test.send(null);
//        test.onreadystatechange = function () {
//            if (test.readyState == 4 && test.status == 200) {
//                var obj = JSON.parse(test.responseText);
//                if (obj['status'] == 1) {
//                    mx = cw * (obj['x'] / 100);
//                    my = ch * (obj['y'] / 100);
//                    mousedown = true;
//                } else {
//
//                }
//            }
//        };
//
//    }
//}


canvas.addEventListener('mousedown', function (e) {
    mx = e.pageX - canvas.offsetLeft;
    my = e.pageY - canvas.offsetTop;
    fireworks.push(new Firework(mx, my, mx, my));
    mousedown = true;
});


canvas.addEventListener('touchstart', function (e) {
    mx = e.pageX - canvas.offsetLeft;
    my = e.pageY - canvas.offsetTop;
    fireworks.push(new Firework(mx, my, mx, my));
    mousedown = true;
});


window.onload = function () {
    loop();
    connect();
}
</script>
</body>
</html>