---
title: Météo - Occitanie
toc: false
theme: [glacier, slate]
---

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
Inputs.table(meteo_31_2023_2024_extrait)
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
