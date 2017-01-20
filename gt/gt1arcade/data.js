// Original content copyright (c) 2002 Adrian Pepper, all rights reserved.
// Contact arpepper at math.uwaterloo.ca  for more information.

var fieldnames =
new Array( "Manufacturer","Model Name","Bonus","&nbsp;","&nbsp;","Rating","&nbsp;","&nbsp;","BHP","Speed","Acc","Hdlng");
var colnames =
new Array( "Manufacturer","Model Name","Bonus Level","Mftr Number","Key Number","Rating","Class","Drive Train","BHP","Max Speed","Acceleration","Handling");

// Note all fields, even numbers must be strings ("276")
var cardata = new Array(
new Array( "Nissan","Skyline GT-R V-spec","0","1","1","85","A","4WD","276","4","5","5"),
new Array( "Nissan","Fairlady Z Version S Twin Turbo 2seater","0","1","2","80","A","FR","276","4","3","3"),
new Array( "Nissan","180SX Type X","0","1","3","60","B","FR","202","3","3","3"),
new Array( "Nissan","Primera","0","1","4","45","C","FF","147","2","1","3"),

new Array( "Honda/Acura","NSX type S","0","2","5","85","A","MR","276","4","5","5"),
new Array( "Honda/Acura","Prelude VTEC","0","2","6","60","B","FF","197","3","3","3"),
new Array( "Honda/Acura","Integra Type R","0","2","7","60","B","FF","197","3","2","5"),
new Array( "Honda/Acura","Civic 3Door Si","0","2","8","50","C","FF","167","2","2","3"),

new Array( "Mazda","efini RX-7 Type RB Bathurst '96","0","3","9","85","A","FR","261","4","5","5"),
new Array( "Mazda","Savanna RX-7 III","0","3","10","68","B","FR","212","2","3","4"),
new Array( "Mazda","Eunos Roadster","0","3","11","40","C","FR","128","1","1","4"),
new Array( "Mazda","Eunos Roadster RS","0","3","12","42","C","FR","128","2","2","4"),

new Array( "Mitsubishi","GTO Twin Turbo '96","0","4","13","83","A","4WD","276","4","5","4"),
new Array( "Mitsubishi","Eclipse","0","4","14","70","B","FF","226","3","5","5"),
new Array( "Mitsubishi","FTO GPX","0","4","15","60","B","FF","197","3","3","5"),
new Array( "Mitsubishi","Mirage Asti RX","0","4","16","48","C","FF","172","2","2","4"),

new Array( "Aston Martin","DB7 Coupe","0","5","17","75","A","FR","335","4","5","2"),
new Array( "Aston Martin","DB7 Volante","0","5","18","75","A","FR","335","4","5","2"),

new Array( "Chevrolet","Camaro Z28","0","6","19","77","A","FR","285","4","4","2"),
new Array( "Chevrolet","Corvette","0","6","20","80","A","FR","330","5","5","3"),
new Array( "Chevrolet","Corvette GS","0","6","21","80","A","FR","330","5","5","3"),
new Array( "Chevrolet","Corvette 427 Coupe","0","6","22","90","A","FR","434","5","5","1"),

new Array( "Toyota","Supra RZ '96","1","7","23","85","A","FR","276","4","4","5"),
new Array( "Toyota","Celica GT-Four","1","7","24","80","A","4WD","251","3","4","4"),
new Array( "Toyota","MR2 GT-S","1","7","25","75","A","MR","241","4","4","5"),
new Array( "Toyota","Soarer 2.5GT-T VVT-i","1","7","26","70","B","FR","236","2","3","3"),

new Array( "Subaru","Impreza WRX STi Version III '96","2","8","27","91","A","4WD","276","3","5","5"),
new Array( "Subaru","Legacy Touring Sedan RS","2","8","28","87","A","4WD","276","3","3","4"),
new Array( "Subaru","Impreza Sports Wagon WRX STi Version III '96","2","8","29","91","A","4WD","276","3","5","5"),
new Array( "Subaru","Legacy Touring Wagon GT-B '96","2","8","30","87","A","4WD","276","3","3","5"),

new Array( "Dodge","Concept Car","3","9","31","85","A","FR","219","5","5","4"),
new Array( "Dodge","Viper GTS","3","9","32","100","A","FR","449","5","5","4"),
new Array( "Dodge","Viper RT/10","3","9","33","95","A","FR","394","5","5","4"),

new Array( "TVR","Cerbera","4","10","34","92","A","FR","350","5","5","3"),
new Array( "TVR","Griffith 500","4","10","35","93","A","FR","340","5","5","4"),
new Array( "TVR","Griffith 4.0","4","10","36","91","A","FR","335","5","5","4")
);
