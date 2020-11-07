-- Les requetes SQL

--Quel est le dernier forfait valide correspondant à un identifiant de carte donné (exemple : carte n°1)

select max(id_forfait) from forfait where id_carte=1 ;

-- 2.Quels sont les noms des remontées de type ’télésiège’
select r.nom_remontee from remontee r,type_remontee tr where tr.id_type_remontee=r.id_type_remontee and tr.libelle_type_remontee='télésiège';

--3.Quels sont les remontées de type ’télésiège’ empruntées avec le forfait n°1
select distinct r.id_remontee,r.nom_remontee from remontee r,type_remontee tr,passage p,forfait f where 
tr.id_type_remontee=r.id_type_remontee and p.id_remontee=r.id_remontee and p.id_carte=f.id_carte and tr.libelle_type_remontee='télésiège' 
and f.id_forfait=1;

--4. Quelles sont les noms des remontées non empruntées avec le forfait n°2
select nom_remontee from remontee
except
select distinct r.nom_remontee from remontee r,passage p,forfait f where p.id_remontee=r.id_remontee and p.id_carte=f.id_carte and 
f.id_forfait=2;

--5. 

select libelle_type_forfait,count(libelle_type_forfait) from type_forfait
group by libelle_type_forfait;

--6 Combien de forfaits ont été utilisés sur toutes les remontées de la station

select count(f.id_forfait) 
from forfait f,passage p where p.id_carte=f.id_carte;

