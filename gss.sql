
drop table carte ;
drop table forfait ;
drop table type_forfait;

-- Creation des tables
select distinct id_type_forfait,libelle_type_forfait,prix,heure_debut,heure_fin,duree_forfait,condition into type_forfait from bd_station;

alter table type_forfait add constraint PK primary key (id_type_forfait);
alter table type_forfait add constraint checkprix check(prix>0 and not null);

select distinct id_carte into carte from bd_station ;
alter table carte add constraint PKc primary key (id_carte);

select distinct id_forfait ,id_type_forfait,id_carte,date_debut into forfait from bd_station ;
alter table forfait add constraint PKf primary key (id_forfait);
alter table forfait add constraint fk1 foreign key (id_type_forfait) references type_forfait(id_type_forfait);

--- Creation d'un trigger verifiant la contrainte 1 et 2

create or replace function carte_utilisee() returns trigger as $carte_util$
declare

nb_forfaits integer ;
new_date_debut date;
new_duree_forfait integer ;

begin

-- on teste la date de debut du nouveau forfait
-- s'il est null alors on met la date du jour dans new_date_debut
if (new.date_debut is null) then
	new_date_debut = (select current_date);
else
	new_date_debut = new.date_debut;
end if;

-- on recupere la duree du forfait
new_duree_forfait = (select duree_forfait from type_forfait where id_type_forfait=new.id_type_forfait) ;
-- requete qui compte le nombre de forfait valide utilisant la carte
nb_forfaits = (select count (f.id_forfait) from forfait f,type_forfait t where (f.date_debut,f.date_debut+t.duree_forfait) overlaps (new_date_debut,new_date_debut+new_duree_forfait) and f.id_type_forfait=t.id_type_forfait and f.id_carte = new.id_carte);
---
if (nb_forfaits > 0) then 
	raise exception 'la carte est pas disponible !!!';
end if ;
new.date_debut = new_date_debut;
return new ;
end

$carte_util$ language plpgsql;

create trigger carte_utilisee before insert
	on forfait for each row 
	execute procedure carte_utilisee();





