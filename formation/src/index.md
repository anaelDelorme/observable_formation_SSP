---
title: Météo - Occitanie
toc: false
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

  p, table, figure, figcaption, h1, h2, h3, h4, h5, h6, .katex-display {
    max-width: 100%;
}
  .hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: var(--sans-serif);
  margin: 4rem 0 8rem;
  text-wrap: balance;
  text-align: center;
}

.hero h1 {
  margin: 2rem 0;
  max-width: none;
  font-size: 14vw;
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(30deg, var(--theme-foreground-focus), currentColor);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero h2 {
  margin: 0;
  max-width: 34em;
  font-size: 20px;
  font-style: initial;
  font-weight: 500;
  line-height: 1.5;
  color: var(--theme-foreground-muted);
}

@media (min-width: 640px) {
  .hero h1 {
    font-size: 90px;
  }
}
  </style>

<div class="hero">
  <h1>Météo en Occitanie</h1>
  <h2>Site Observable créé dans le cadre de la formation interne SSP</h2>
</div>


```js
// import des données de la Haute-Garonne en 2023 et 2024
const meteo_31_2023_2024 = FileAttachment("data/Q_31_latest-2023-2024_RR-T-Vent.csv").csv();
const meteo_34_2023_2024 = FileAttachment("data/Q_34_latest-2023-2024_RR-T-Vent.csv").csv();

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
```

```js
//un tableau simple avec juste le nom des stations météo
const nomsStations = Array.from(new Set(meteo_31_2023_2024_extrait.map(d => d.nom_poste)));
const datesMesures = Array.from(new Set(meteo_31_2023_2024_extrait.map(d => d.date)));

```

## Graphique des températures et précipitations selon la station météo
```js
//On met ça dans un Inputs.select et un view pour l'afficher
const nomsStations_choix = view(Inputs.select(nomsStations, {label: "Station météo :"}));

```
```js
// Options pour le formatage de la date
const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
const nom_poste_recherche = nomsStations_choix;
const date_recherche = new Date(date_choix);
// Conversion de l'objet Date en chaîne de caractères au format souhaité
const dateString = date_recherche.toLocaleDateString('fr-FR', options).split('/').join('-');

const objetTrouve = meteo_31_2023_2024_extrait.find(
  obj => obj.nom_poste === nom_poste_recherche && obj.date.getTime() === date_recherche.getTime()
);
``` 


```js
// Filtrer les données pour le poste choisi
const donneesFiltrees = meteo_31_2023_2024_extrait.filter(d => d.nom_poste === nom_poste_recherche);

// Créer un graphique combiné pour temp_min et temp_max
function graphiqueTemp(data, {width}) {
  return Plot.plot({
    width,
  title: "Températures minimales et maximales pour "+nom_poste_recherche,
  y: {grid: true, inset: 10, label: "Température (°C)"},
  marks: [
    Plot.lineY(data, {
      x: "date",
      y: "temp_min",
      stroke: "steelblue",
      label: "Temp. min"
    }),
    Plot.lineY(data, {
      x: "date",
      y: "temp_max",
      stroke: "tomato",
      label: "Temp. max"
    })
  ]
})};

```

```js
// Créer un graphique combiné pour temp_min et temp_max
function graphiquePrecipitation(data, {width}) {
  return Plot.plot({
      width,title: "Précipitations pour "+nom_poste_recherche,
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
}
  ```

```js
// Créer un graphique combiné pour temp_min et temp_max
function carteTemperature(data, {width}) {

}
```


<div class="grid grid-cols-2">
  <div class="card">
    ${resize((width) => graphiqueTemp(donneesFiltrees, {width}))}

  </div>
  <div class="card">    
    ${resize((width) => graphiquePrecipitation(donneesFiltrees, {width}))}
  </div>
</div>

<div class="grid grid-cols-1">

  ## Carte des températures
  
</div>

```js
const date_choix = view(Inputs.select(datesMesures, {label: "Date : "}));
const choix_variable = view(Inputs.radio(["Température min", "Température max"], {label: "Variable à afficher : "}));

```
```js
console.log(date_choix)
// Filtrer les données pour la date du 21-05-2023
const donneesDuJour = meteo_31_2023_2024_extrait.filter(d => d.date.getTime() === date_choix.getTime());
console.log(donneesDuJour)

 function choseColorTemp(value) {
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
  let variable_choisi;
  if (choix_variable === "Température min") {
    variable_choisi = station.temp_min;
  } else {
    variable_choisi = station.temp_max;
  }
  const color = choseColorTemp(variable_choisi);
  const marker = L.marker([station.lat, station.lon], {
    icon: L.divIcon({
                       html: '<div style="background:'+color+';">' + variable_choisi.toFixed(1) + '°</div>',
                       iconSize:[40, 20], 
                      className: 'myIcon'   // Classe CSS pour le style
    }),
    zIndexOffset: 1000     // S'assurer que le label est au-dessus des autres couches
  }).addTo(map);
  marker.bindPopup(`Station de ${station.nom_poste.charAt(0).toUpperCase() + station.nom_poste.slice(1).toLowerCase()} </br> Température min: ${station.temp_min.toFixed(1)}°C </br> Température max: ${station.temp_max.toFixed(1)}°C </br> Précipitations: ${station.precipitation.toFixed(1)}mm`);
});
```


