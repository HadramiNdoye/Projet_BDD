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
	raise exception 'la carte % n''est pas disponible!!!',new.id_carte;
end if ;
new.date_debut = new_date_debut;
return new ;
end

$carte_util$ language plpgsql;

create trigger carte_utilisee before insert
	on forfait for each row 
	execute procedure carte_utilisee();
	
--- Creation d'un trigger verifiant la contrainte 3

create or replace function forfait_invalide() returns trigger as $forfait_inv$
declare

new_heure_debut time without time zone;
new_heure_fin time without time zone;
new_libelle_type_forfait character varying(30);
new_duree_forfait integer;
nb_remontee integer;

begin
-- on recupere heure_debut
new_heure_debut = (select t.heure_debut from type_forfait t,forfait f where new.id_carte=f.id_carte and f.id_type_forfait=t.id_type_forfait);

-- on recupere heure_fin
new_heure_fin = (select t.heure_fin from type_forfait t,forfait f where new.id_carte=f.id_carte and f.id_type_forfait=t.id_type_forfait);

-- on recupere libelle_type_forfait
new_libelle_type_forfait = (select t.libelle_type_forfait from type_forfait t,forfait f where new.id_carte=f.id_carte and f.id_type_forfait=t.id_type_forfait);

-- on recupere la duree du forfait
new_duree_forfait = (select t.duree_forfait from type_forfait t,forfait f where new.id_carte=f.id_carte and f.id_type_forfait=t.id_type_forfait);

-- On recupere le nombre de remontee
--nb_remontee = (select count(f.id_forfait) from forfait f where f.id_carte=new.id_carte);


if(new_libelle_type_forfait='matinée') then

	if(select(time without time zone '09:00:00',time without time zone '14:00:00') overlaps (new_heure_debut,new_heure_fin) = false or
	 new_duree_forfait > 1) then
			raise exception 'le forfait de la carte % n''est pas valide!!!',new.id_carte;
	end if;
end if;
if(new_libelle_type_forfait='semaine') then

	if(select(time without time zone '09:00:00',time without time zone '17:00:00') overlaps (new_heure_debut,new_heure_fin) = false or 
		new_duree_forfait > 7) then
			raise exception 'le forfait de la carte % n''est pas valide!!!',new.id_carte;
	end if;
end if;
if(new_libelle_type_forfait='journée') then

	if(select(time without time zone '09:00:00',time without time zone '17:00:00') overlaps (new_heure_debut,new_heure_fin) = false or 
		new_duree_forfait > 1) then
			raise exception 'le forfait de la carte % n''est pas valide!!!',new.id_carte;
	end if;
end if;

return new;					
end

$forfait_inv$ language plpgsql;

create trigger forfait_invalide before insert
	on passage for each row 
	execute procedure forfait_invalide();
	
-- Requetes pour tester les trigger
--triggers 1 et 2

insert into forfait values(25001,2,5934); -- insertion d'un nouveau forfait dont la date debut est null
insert into forfait values(25002,2,5934) ;

--triggers 3 et 4
insert into type_forfait values(25,'matinée',20,'10:00:00',':13:00:00',1);
insert into carte values(7001);
insert into forfait values(25003,25,7001,'20-12-2020');
insert into passage values(7001,2,'2008-12-27 11:21:43.28');

