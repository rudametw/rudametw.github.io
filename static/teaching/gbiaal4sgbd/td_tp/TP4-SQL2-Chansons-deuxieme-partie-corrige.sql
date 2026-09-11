/* TP4 */

/* 1. Combien de chansons il y a dans la base? */
select count(*) from chanson ;

/* Vérifiez si "mistral gagnant" s'y retrouve.*/


/* Si non, ajoutez cette chanson, parue en 1985. */

INSERT INTO chanson(c_ref, c_titre, c_annee) VALUES (50,'mistral gagnant',1985);

/* 2. Ajoutez Renaud dans la liste des chanteurs. */

INSERT INTO chanteur(n_ref,n_nom) VALUES (18,'renaud');

/* 3a. Comment ajouter dans la base l'information que Renaud est l'interprète de la chanson "Mistral gagnant?"

Il faut aussi inserrer une nouvelle valeur dans la relation "interprete". Mais, comme de plus on a une contrainte sur la valeur du disque qui ne doit pas être nulle, on a besoin d'une nouvelle information.  */

INSERT INTO interprete (i_chanson, i_chanteur) VALUES (50,18);
ERROR:  null value in column "i_disque" violates not-null constraint.

/* 3b. De quelle nouvelle information a-t'on besoin? Recherchez-la et modifiez la base.

Album éponyme. On rajoute la référence(PK) et le titre du disque dans la base. */

INSERT INTO disque (d_ref, d_titre) VALUES (20,'mistral gagnant');

/* On refait la modification de la table interprete. */

INSERT INTO interprete (i_disque,i_chanson, i_chanteur) VALUES (20,50,18);


/* 4. On souhaite avoir dans la base la chanson "petite marie" chantée par Cabrel, de l'album 'Murs de poussière', sorti en 1977.

4a. Quelles informations sont déjà présentes dans la base? */

select * from chanteur where n_nom = 'cabrel' ;   /* cabrel est là (n_ref 17) */
select * from chanson where c_titre like 'pet%' ; /* petite marie n'est pas là */
select * from disque where d_titre like 'murs%' ; /* murs de poussiere n'est pas là */

/* 4b. Faites toutes les opérations nécéssaires pour ajouter cette chanson correctement. */

INSERT INTO chanson(c_ref, c_titre, c_annee) VALUES (51,'petite marie',1977);
INSERT INTO disque (d_ref, d_titre) VALUES (21,'murs de poussierre');
INSERT INTO interprete (i_disque,i_chanson, i_chanteur) VALUES (21,51,17);


/* 5a Modifiez la base pour faire apparaître tous les noms des catégories avec majuscules. (Utilisez UPDATE.)*/

UPDATE categorie SET  c_libelle = UPPER(c_libelle);

/* 5b. Renommez la colonne c_libelle par c_lib_majuscule. (Utilisez ALTER.) */

ALTER TABLE categorie RENAME  c_libelle TO c_lib_upper;

/* 6a. Rajouter l’attribut ’date de naissance’ à la table chanteur. */

ALTER TABLE chanteur ADD date_naissance date;

/* 6b. Mettez à jour les informations des chanteurs Renaud et Cabrel en ajoutant leurs dates de naissance. */

UPDATE chanteur SET date_naissance='1953-11-23'  where n_nom='cabrel';
UPDATE chanteur SET date_naissance='1952-05-11'  where n_nom='renaud';
