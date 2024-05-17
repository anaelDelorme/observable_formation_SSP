---
title: Météo - Tests de prise en main
toc: false
theme: [glacier, slate]
---
<style>
    * {
      box-sizing: border-box;
    }

    #map {
        position: absolute;
        top:0;
        left: 0;
        right: 0;
        bottom:0;
    }

    .myIcon div {
      display: flex; /* Utiliser flexbox pour centrer le contenu */
      justify-content: center; /* Centrer horizontalement */
      align-items: center; /* Centrer verticalement */
      border: solid grey 1px;
      border-radius: 100%;
      opacity: 80%;
      height: 100%;
      width: 100%;
      }

  
  </style>

# Météo en Occitanie

```js
// import des données de la Haute-Garonne en 2023 et 2024
const meteo_31_2023_2024 = FileAttachment("data/Q_31_latest-2023-2024_RR-T-Vent.csv").csv();

// Affichage du tableau --> Promise
display(meteo_31_2023_2024);
``` 

```js
// Affichage du tableau --> Promise résolue
display(meteo_31_2023_2024);
``` 
```js

// Fonction pour transformer le champ date
  function convertToDate(aaaammjj) {
  
  if (/^\d{8}$/.test(aaaammjj)) {
    const year = aaaammjj.substring(0, 4);
    const month = aaaammjj.substring(4, 6);
    const day = aaaammjj.substring(6, 8);

    // Créer un nouvel objet Date
    return new Date(`${year}-${month}-${day}`);
  } else {
    throw new Error('La chaîne doit être au format AAAAMMJJ');
  }
}

function extractProperties(obj) {
  const properties = obj["NUM_POSTE;NOM_USUEL;LAT;LON;ALTI;AAAAMMJJ;RR;QRR;TN;QTN;HTN;QHTN;TX;QTX;HTX;QHTX;TM;QTM;TNTXM;QTNTXM;TAMPLI;QTAMPLI;TNSOL;QTNSOL;TN50;QTN50;DG;QDG;FFM;QFFM;FF2M;QFF2M;FXY;QFXY;DXY;QDXY;HXY;QHXY;FXI;QFXI;DXI;QDXI;HXI;QHXI;FXI2;QFXI2;DXI2;QDXI2;HXI2;QHXI2;FXI3S;QFXI3S;DXI3S;QDXI3S;HXI3S;QHXI3S"].split(";");
  
  // Fonction pour vérifier si une valeur est numérique
  function isNumeric(value) {
    return !isNaN(value) && isFinite(value);
  }

  // Convertir les valeurs en nombres si elles sont numériques
  const precipitation = isNumeric(properties[6]) ? Number(properties[6]) : null;
  const temp_min = isNumeric(properties[8]) ? Number(properties[8]) : null;
  const temp_max = isNumeric(properties[12]) ? Number(properties[12]) : null;
  const ampli_thermique = isNumeric(properties[20]) ? Number(properties[20]) : null;
  const duree_gel_minute = isNumeric(properties[26]) ? Number(properties[26]) : null;

const dateformatee = convertToDate(properties[5]);

  return {
    id_poste: properties[0], 
    nom_poste: properties[1], 
    lat: properties[2], 
    lon: properties[3], 
    date: dateformatee,
    precipitation: precipitation,
    temp_min: temp_min,
    temp_max: temp_max,
    ampli_thermique: ampli_thermique,
    duree_gel_minute: duree_gel_minute
  };
}
const meteo_31_2023_2024_extrait = meteo_31_2023_2024.map(extractProperties);
display(meteo_31_2023_2024_extrait);
```

```js
// Options pour le formatage de la date
const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
const nom_poste_recherche = "ARBAS";
const date_recherche = new Date("2023-05-21");
// Conversion de l'objet Date en chaîne de caractères au format souhaité
const dateString = date_recherche.toLocaleDateString('fr-FR', options).split('/').join('-');

const objetTrouve = meteo_31_2023_2024_extrait.find(
  obj => obj.nom_poste === nom_poste_recherche && obj.date.getTime() === date_recherche.getTime()
);
display(objetTrouve)
``` 

Les températures minimale et maximale pour la station **${nom_poste_recherche}** à la date du **${dateString}** sont **${objetTrouve.temp_min}°C** et **${objetTrouve.temp_max}°C**.


```js
// Création d'une table d'affichage de mes données
display(Inputs.table(meteo_31_2023_2024_extrait))
```



```js
// Trouver la valeur maximale des précipitations
const maxPrecipitation = Math.max(...meteo_31_2023_2024_extrait.map(d => d.precipitation));
display(maxPrecipitation)
// Création d'une table d'affichage avec mise en forme
display(Inputs.table(meteo_31_2023_2024_extrait,
    {
      columns: [
        "nom_poste",
        "date",
        "temp_min",
        "temp_max",
        "precipitation"
      ],
      header: {
        nom_poste: "Poste météo",
        date: "Date",
        temp_min: "Température min. (°C)",
        temp_max: "Température max. (°C)",
        precipitation: "Précipitation (mm)"
      },
      format: {
          nom_poste: (x) => x.charAt(0).toUpperCase() + x.slice(1).toLowerCase(),
          date: (x) => x.toLocaleDateString('fr-FR', options).split('/').join('-'),
          temp_min: (x) => {
            const temp = x.toFixed(1);
            if (x > 25) {
              return html`<span style="color: green;">${temp}</span>`; // Vert si supérieur à 25
            } else if (x < 0) {
              return html`<span style="color: red;">${temp}</span>`; // Rouge si négatif
            } else {
              return temp; // Aucune couleur si entre 0 et 25
            }
          },
          temp_max: (x) => {
            const temp = x.toFixed(1);
            if (x > 25) {
              return html`<span style="color: green;">${temp}</span>`; // Vert si supérieur à 25
            } else if (x < 0) {
              return html`<span style="color: red;">${temp}</span>`; // Rouge si négatif
            } else {
              return temp; // Aucune couleur si entre 0 et 25
            }
          },
          precipitation: (x) => {
            const temp = x.toFixed(1);
            const barLength = (x / maxPrecipitation) * 100;
            return html`<div style="
                  background: var(--theme-blue); 
                  color: black;
                  width: ${barLength}%; 
                  height: 20px;
                  float: right;
                  padding-right: 3px;
                  box-sizing: border-box;
                  overflow: visible;
                  display: flex;
                  justify-content: end;">
                    ${temp}
                  </div>`;
          }
        }
    })
)
```


```js
// Filtrer les données pour le poste "AUZEVILLE-TOLOSANE-INRA"
const donneesFiltrees = meteo_31_2023_2024_extrait.filter(d => d.nom_poste === "AUZEVILLE-TOLOSANE-INRA");

// Créer un graphique combiné pour temp_min et temp_max
const graphiqueTemp = Plot.plot({
  title: "Températures minimales et maximales pour  Auzeville-Tolosane-INRA",
  y: {grid: true, inset: 10, label: "Température (°C)"},
  marks: [
    Plot.lineY(donneesFiltrees, {
      x: "date",
      y: "temp_min",
      stroke: "steelblue",
      label: "Temp. min"
    }),
    Plot.lineY(donneesFiltrees, {
      x: "date",
      y: "temp_max",
      stroke: "tomato",
      label: "Temp. max"
    })
  ]
});

// Afficher le graphique
display(graphiqueTemp);
```

```js
// Créer un graphique pour les précipitations
const barTemp = Plot.plot({
  title: "Précipitations pour Auzeville-Tolosane-INRA",
  y: {grid: true, label: "Précipitations (mm)"},
  x: {
    grid: true,
    label: "Date",
    // Utiliser une fonction pour filtrer les ticks pour afficher un tick tous les 3 mois
    ticks: d3.utcMonth.every(3)
  },
  marks: [
    Plot.barY(donneesFiltrees, {
      x: "date",
      y: "precipitation",
      fill: "darkslateblue"
          }),
    Plot.ruleY([0])
  ]
});

// Afficher le graphique
display(barTemp);
```

```js
// Filtrer les données pour la date du 21-05-2023
const donneesDuJour = meteo_31_2023_2024_extrait.filter(d => d.date.toISOString().startsWith("2023-05-21"));

// Créer la section de la page (div) qui contiendra la carte
const div = display(document.createElement("div"));
div.style = "height: 400px;";

// Créer la carte avec leaflet et centrer sur la Haute-Garonne
const map = L.map(div)
  .setView([43.2927, 1.8828], 8);

// Ajouter une couche de tuiles à la carte
L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
})
  .addTo(map);

// Ajouter un marqueur pour chaque station météo
donneesDuJour.forEach(station => {
  L.marker([station.lat, station.lon]) // création d'un marker aux coordonées de la station
    .addTo(map)   // que l'on ajoute à la carte qui s'appelle map
    .bindPopup(`Station de ${station.nom_poste} </br> Température min: ${station.temp_min}°C </br> Température max: ${station.temp_max}°C </br> Précipitations: ${station.precipitation}mm`); // et ajout d'un popup qui contient les infos pertinentes
})
```

```js
 function choseColor(value) {
          if (value < 0) {
                return "#7EBCF2";
          } else if (value < 10) {
                return "#7E97F2";
          } else if (value < 20) {
                return "#F2C335";
          } else if (value < 30) {
                return "#F29422";
          } else {
                return "#F21313";
          }
    };

// Initialiser la carte Leaflet
const div = display(document.createElement("div"));
div.style = "height: 400px;";

// Insérer la carte dans le div
const map = L.map(div)
  .setView([43.2927, 1.8828], 8);

// Ajouter une couche de tuiles à la carte
 L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
	attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
	subdomains: 'abcd'}).addTo(map);

// Ajouter un marqueur pour chaque station météo
donneesDuJour.forEach(station => {
  const color = choseColor(station.temp_max);
  const marker = L.marker([station.lat, station.lon], {
    icon: L.divIcon({
                       html: '<div style="background:'+color+';">' + station.temp_max.toFixed(1) + '°</div>',
                       iconSize:[40, 20], 
                      className: 'myIcon'   // Classe CSS pour le style
    }),
    zIndexOffset: 1000     // S'assurer que le label est au-dessus des autres couches
  }).addTo(map);
  marker.bindPopup(`Station de ${station.nom_poste.charAt(0).toUpperCase() + station.nom_poste.slice(1).toLowerCase()} </br> Température min: ${station.temp_min.toFixed(1)}°C </br> Température max: ${station.temp_max.toFixed(1)}°C </br> Précipitations: ${station.precipitation.toFixed(1)}mm`);
});
```

```js
//un tableau simple avec juste le nom des stations météo
const nomsStations = Array.from(new Set(meteo_31_2023_2024_extrait.map(d => d.nom_poste)));

//On met ça dans un Inputs.select et un view pour l'afficher
const nomsStations_choix = view(Inputs.select(nomsStations, {label: "Choisir une station météo"}));

```
```js
// Filtrage des données avec le résultat de l'input select
const donneesChoisies = meteo_31_2023_2024_extrait.filter(d => d.nom_poste === nomsStations_choix);

//affichage du tableau 
display(Inputs.table(donneesChoisies))
```