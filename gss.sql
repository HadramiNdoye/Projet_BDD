-- Creation des tables--
select distinct id_type_forfait,libelle_type_forfait,prix,heure_debut,heure_fin,duree_forfait,condition into type_forfait from bd_station;

alter table type_forfait add constraint PK primary key (id_type_forfait);

select id_carte into carte from bd_station ;

