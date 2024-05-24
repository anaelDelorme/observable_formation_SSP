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
const meteo_init =  FileAttachment("data/meteo.json").json();
``` 

```js

// Fonction pour transformer le champ date
  function convertToDate(aaaammjj) {
  const data_char = aaaammjj.toString();
  if (/^\d{8}$/.test(data_char)) {
    const year = data_char.substring(0, 4);
    const month = data_char.substring(4, 6);
    const day = data_char.substring(6, 8);

    // Créer un nouvel objet Date
    return new Date(`${year}-${month}-${day}`);
  } else {
    throw new Error('La chaîne doit être au format AAAAMMJJ');
  }
}

let meteo = meteo_init.map(element => {
  return {
    ...element,
    date: convertToDate(element.date)
  };
});

```

```js
//un tableau simple avec juste le nom des stations météo

const nomsStationsUniques = Array.from(new Set(meteo.map(d => d.nom_poste)))
  .reduce((acc, nom_poste) => {
    // Utiliser nom_poste comme clé pour éliminer les doublons
    if (!acc[nom_poste]) {
      acc[nom_poste] = {
        nom_poste: nom_poste,
        code_departement: meteo.find(d => d.nom_poste === nom_poste).code_departement,
        nom_poste_formate: nom_poste.charAt(0).toUpperCase() + nom_poste.slice(1).toLowerCase()
      };
    }
    return acc;
  }, {});

// Convertir l'objet en tableau
const nomsStations = Object.values(nomsStationsUniques);

// Trier le tableau par les noms formatés en ordre alphabétique
const nomsStationsTriesEtFormates = nomsStations.sort((a, b) => 
  a.nom_poste_formate.localeCompare(b.nom_poste_formate)
);

```


## Graphique des températures et précipitations selon la station météo
```js
const nomsStations_choix = view(Inputs.select(nomsStationsTriesEtFormates, {
  label: "Station météo :",
  value: d => d.nom_poste, // La valeur renvoyée lorsqu'un élément est sélectionné
  format: d => d.nom_poste_formate + " ("+d.code_departement+")" // Comment les éléments sont affichés dans la liste déroulante
}));
```
```js
// Options pour le formatage de la date
const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
const nom_poste_recherche = nomsStations_choix.nom_poste;
const date_recherche = new Date(date_choix);
// Conversion de l'objet Date en chaîne de caractères au format souhaité
const dateString = date_recherche.toLocaleDateString('fr-FR', options).split('/').join('-');

const objetTrouve = meteo.find(
  obj => obj.nom_poste === nom_poste_recherche && obj.date.getTime() === date_recherche.getTime()
);
``` 


```js
// Filtrer les données pour le poste choisi
const donneesFiltrees = meteo.filter(d => d.nom_poste === nomsStations_choix.nom_poste);

// Créer un graphique combiné pour temp_min et temp_max
function graphiqueTemp(data, {width}) {
  return Plot.plot({
    width,
  title: "Températures minimales et maximales pour "+nomsStations_choix.nom_poste_formate+" ("+nomsStations_choix.code_departement+")",
  y: {grid: true, inset: 10, label: "Température (°C)"},
  marks: [
    Plot.lineY(data, {
      x: "date",
      y: "temp_min",
      stroke: "steelblue",
      label: "Temp. min",
      k: 10, 
      reduce: "mean"
    }),
    Plot.lineY(data, {
      x: "date",
      y: "temp_max",
      stroke: "tomato",
      label: "Temp. max",
      k: 10, 
      reduce: "mean"
    })
  ]
})};

```

```js
// Créer un graphique combiné pour temp_min et temp_max
function graphiquePrecipitation(data, {width}) {
  return Plot.plot({
      width,title: "Précipitations pour "+nomsStations_choix.nom_poste_formate+" ("+nomsStations_choix.code_departement+")",
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
const date_choix = view(Inputs.date({label: "Date", value: "2023-01-01", min: "2023-01-01", max: "2024-05-21"}));
const choix_variable = view(Inputs.radio(["Température min", "Température max"], {label: "Variable à afficher : ", value:"Température min"}));
```

```js
// Filtrer les données pour la date choisie
const donneesDuJour = meteo.filter(d => d.date.getTime() === date_choix.getTime());
```

```js
 function choseColorTemp(value) {
          if (value < 0) {
                return "#7EBCF2";
          } else if (value < 10) {
                return "#7E97F2";
          } else if (value < 20) {
                return "#F2C335";
          } else if (value < 30) {
                return "#F29422";
          } else if (value > 30) {
                return "#F21313";
          } else {
                return "#0f2537";
          }
    };

// Initialiser la carte Leaflet
const div = display(document.createElement("div"));
div.style = "height: 400px;";

// Insérer la carte dans le div
const map = L.map(div)
  .setView([43.8927, 1.8828], 7);

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
  if (variable_choisi !== undefined) {
      const color = choseColorTemp(variable_choisi);
      const marker = L.marker([station.lat, station.lon], {
        icon: L.divIcon({
                          html: '<div style="background:'+color+';">' + variable_choisi + '°</div>',
                          iconSize:[40, 20], 
                          className: 'myIcon'   // Classe CSS pour le style
        }),
        zIndexOffset: 1000     // S'assurer que le label est au-dessus des autres couches
      }).addTo(map);
    marker.bindPopup(`Station de ${station.nom_poste.charAt(0).toUpperCase() + station.nom_poste.slice(1).toLowerCase()} </br> Température min: ${station.temp_min !== undefined ? station.temp_min + '°C' : '?'}</br> Température max: ${station.temp_max !== undefined ? station.temp_max + '°C' : '?'} </br> Précipitations: ${station.precipitation !== undefined ? station.precipitation + 'mm' : '?'}`);
    }
  }  
    );
  
```


