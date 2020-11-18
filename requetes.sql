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

select tf.libelle_type_forfait,count(f.id_forfait) from type_forfait tf,forfait f where tf.id_type_forfait = f.id_type_forfait
group by tf.libelle_type_forfait;

--6 Combien de forfaits ont été utilisés sur toutes les remontées de la station

select count(f.id_forfait) 
from forfait f,passage p where p.id_carte=f.id_carte;


--7 

select id_carte, count(*) as Nb_forfait from forfait 
group by id_carte having count(*)>=all(select count(*) as Nb_forfait from forfait
group by id_carte);

--8 
select count(*) from passage;

select p.id_remontee, r.nom_remontee, count(*) as Nb_Passage from passage p, remontee r 
where p.id_remontee=r.id_remontee group by p.id_remontee, r.nom_remontee order by p.id_remontee asc;



--9


-- 10
select p.id_remontee,r.nom_remontee, count(*) as Nb_remontee from passage p, remontee r 
where p.id_remontee=r.id_remontee group by p.id_remontee,r.nom_remontee having count(*)>=all(select count(*) as Nb_remontee from passage p, remontee r 
where p.id_remontee=r.id_remontee group by p.id_remontee,r.nom_remontee);


-- 11
select p.id_remontee,r.nom_remontee, count(*) as Nb_remontee from passage p, remontee r 
where p.id_remontee=r.id_remontee group by p.id_remontee,r.nom_remontee having count(*)<=all(select count(*) as Nb_remontee from passage p, remontee r 
where p.id_remontee=r.id_remontee group by p.id_remontee,r.nom_remontee);


-- 12
select f.id_forfait, t.libelle_type_forfait, count(*) as Nb_fois_utilise 
from forfait f, type_forfait t, passage p 
where f.id_type_forfait=t.id_type_forfait and f.id_carte=p.id_carte
group by f.id_forfait, t.libelle_type_forfait having count(*)>=all(select count(*) as Nb_fois_utilise 
from forfait f, type_forfait t, passage p 
where f.id_type_forfait=t.id_type_forfait and f.id_carte=p.id_carte
group by f.id_forfait, t.libelle_type_forfait);

--13 

select sum(t.prix) as Chiffre_affaire from type_forfait t, forfait f where t.id_type_forfait=f.id_type_forfait;


--14 ok
select date_trunc('month', f.date_debut), sum(t.prix) as Chiffre_affaire from type_forfait t, forfait f 
where t.id_type_forfait=f.id_type_forfait
group by date_trunc('month', f.date_debut) order by date_trunc('month', f.date_debut) asc;

