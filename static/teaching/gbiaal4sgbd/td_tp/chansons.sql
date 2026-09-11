-- source de creation de la base chansons


create table CATEGORIE (
  c_ref     integer constraint categorie_pkey
                      primary key,-- obligatoirement not null et unique
  c_libelle varchar(15) not null
);

create table DISQUE (
  d_ref   integer constraint disque_pkey 
                    primary key, 
  d_titre varchar(20) not null,
  d_annee integer,
  d_categ integer,
  constraint disque_categ_fkey
  foreign key (d_categ) references categorie(c_ref) 
  -- la table categorie doit etre creee avant la table disque
);

create table CHANTEUR ( -- individu ou groupe
  n_ref    integer constraint chanteur_pkey
                     primary key,
  n_nom    varchar(20) not null,
  n_prenom varchar(10)
);

create table CHANSON (
  c_ref   integer constraint chanson_pkey
                    primary key,
  c_titre varchar(30) not null,
  c_annee integer
);

create table GROUPE (
  g_refgroupe integer constraint groupe_nomgroupe_fkey
                        references chanteur(n_ref),
  g_refpers   integer constraint groupe_nompers_fkey
                        references chanteur(n_ref),
  constraint groupe_pkey primary key(g_refgroupe,g_refpers)
);

create table INTERPRETE (
  i_disque  integer constraint interprete_disque_fkey
                      references disque(d_ref),
  i_chanson integer constraint interprete_chanson_fkey
                      references chanson(c_ref),
  i_chanteur     integer constraint interprete_chanteur_fkey
                      references chanteur(n_ref),
  constraint interprete_pkey primary key(i_disque,i_chanson,i_chanteur)
);  


insert into CHANTEUR values (1 , 'bashung', 'alain') ;
insert into CHANTEUR values (2 , 'souchon', 'alain') ;
insert into CHANTEUR values (3 , 'chamfort', 'alain');
insert into CHANTEUR values (4 , 'springsteen', 'bruce');
insert into CHANTEUR values (5 , 'les innocents', null);
insert into CHANTEUR values (6 , 'telephone', null);
insert into CHANTEUR values (7 , 'aubert', 'jean-louis');
insert into CHANTEUR values (8 , 'bertignac', 'louis');
insert into CHANTEUR values (9 , 'kolinka', 'richard');
insert into CHANTEUR values (10, 'marienneau','corinne');
insert into CHANTEUR values (11 , 'mc solar', null);

insert into CATEGORIE values (1, 'variete');
insert into CATEGORIE values (2, 'rock') ;
insert into CATEGORIE values (3, 'reggae') ;
insert into CATEGORIE values (4, 'rap') ;
insert into CATEGORIE values (5, 'chants enfants') ;
insert into CATEGORIE values (6, 'techno') ;
insert into CATEGORIE values (7,'jazz') ;

-- bruce springsteen (reference = 4)

insert into DISQUE values (1,'born to run',1975,2) ;
insert into DISQUE values (2,'greetings from asbur',1975,2);
insert into DISQUE values (3,'greatest hits',1995,2);
insert into DISQUE values (4,'the river',1980,2);

-- album 4 (et 3)

insert into CHANSON values (1,'two hearts',1980);
insert into CHANSON values (2,'independence day',1980);
insert into CHANSON values (3,'hungry heart',1979);
insert into CHANSON values (4,'the river',1979);

insert into INTERPRETE values (4,1,4) ; 
-- disque,chanson,nom
insert into INTERPRETE values (4,2,4) ;
insert into INTERPRETE values (4,3,4) ;
insert into INTERPRETE values (4,4,4) ;
insert into INTERPRETE values (3,3,4) ;
insert into INTERPRETE values (3,4,4) ;

-- album 1

insert into CHANSON values (5,'born to run',1974);
insert into CHANSON values (6,'thunder road',1975) ;
insert into CHANSON values (7,'night',1975) ;

insert into INTERPRETE values(1,5,4);
insert into INTERPRETE values(1,6,4);
insert into INTERPRETE values(1,7,4);
insert into INTERPRETE values(3,5,4);
insert into INTERPRETE values(3,6,4);

-- album 2

insert into CHANSON values (8,'blinded by the light',1975);
insert into CHANSON values (9,'growin''up',1975);

insert into INTERPRETE values (2,8,4);
insert into INTERPRETE values (2,9,4);

-- album 3

insert into CHANSON values (10,'born in the USA',1984);
insert into CHANSON values (11,'streets of philadelphia',1993);

insert into INTERPRETE values (3,10,4);
insert into INTERPRETE values (3,11,4);

---------------------------------------------------------------------

-- alain bashung (reference = 1)
insert into DISQUE values (5,'chatterton',1994,2) ;
insert into DISQUE values (6,'confessions publique',1995,2) ;
insert into DISQUE values (7,'fantaisie militaire',1998,2) ;

-- album 5
insert into CHANSON values (12,'a perte de vue',1994);
insert into CHANSON values (13,'que n''ai-je',1994);
insert into CHANSON values (14,'ma petite entreprise',1994);

insert into INTERPRETE values(5,12,1);
insert into INTERPRETE values(5,13,1);
insert into INTERPRETE values(5,14,1);

-- album 7
insert into CHANSON values (18,'malaxe',1998);
insert into CHANSON values (19,'la nuit je mens',1998);
insert into CHANSON values (20,'fantaisie militaire',1998);

insert into INTERPRETE values (7,18,1);
insert into INTERPRETE values (7,19,1);
insert into INTERPRETE values (7,20,1);

-- album 6
insert into CHANSON values (15,'bijou bijou', 1979);
insert into CHANSON values (16,'madame reve', 1991);
insert into CHANSON values (17,'rebel', 1981);

insert into INTERPRETE values (6,14,1);
insert into INTERPRETE values (6,15,1);
insert into INTERPRETE values (6,17,1);
insert into INTERPRETE values (6,16,1);
insert into INTERPRETE values (6,12,1);

----------------------------------------------------------------------
-- jean-louis aubert (reference = 7)
insert into DISQUE values (10,'stockholm',1997,2) ;

insert into CHANSON values (21,'stockholm',1997);
insert into CHANSON values (22,'ocean',1997);

insert into INTERPRETE values (10,21,7);
insert into INTERPRETE values (10,22,7);

-- telephone (reference = 6)
insert into DISQUE values (9,'la totale',1994,2);
insert into DISQUE values (8,'rappels',1991,2);


insert into CHANSON values (24,'hygiaphone',1977);
insert into CHANSON values (23,'la bombe humaine',1979);
insert into CHANSON values (26,'metro (c''est trop)',1977);
insert into CHANSON values (25,'dure limite',1980);
insert into CHANSON values (27,'un autre monde',1984);

insert into INTERPRETE values(9,23,6);
insert into INTERPRETE values(9,24,6);
insert into INTERPRETE values(9,26,6);
insert into INTERPRETE values(9,25,6);
insert into INTERPRETE values(8,24,6);
insert into INTERPRETE values(8,23,6);
insert into INTERPRETE values(8,25,6);
insert into INTERPRETE values(8,27,6);
insert into INTERPRETE values(9,27,6);

insert into GROUPE values(6,7);
insert into GROUPE values(6,8);
insert into GROUPE values(6,9);
insert into GROUPE values(6,10);
---------------------------------------------------------------------

-- alain souchon (reference = 2)

insert into DISQUE values (12,'jamais content',1977,1);
insert into DISQUE values (11,'c''est deja ca',1993,1);
insert into DISQUE values (13,'nickel',1990,1);

-- album 12
insert into CHANSON values (28,'jamais content',1977);
insert into CHANSON values (29,'poulaillers''song',1977);

insert into INTERPRETE values (12,28,2);
insert into INTERPRETE values (12,29,2);

-- album 11
insert into CHANSON values (30,'c''est deja ca',1993);
insert into CHANSON values (31,'foule sentimentale',1993);
insert into CHANSON values (32,'les regrets',1993);
insert into CHANSON values (33,'arlette laguiller',1993);

insert into INTERPRETE values (11,30,2);
insert into INTERPRETE values (11,31,2);
insert into INTERPRETE values (11,32,2);
insert into INTERPRETE values (11,33,2);

-- album 13
insert into CHANSON values (34,'les jours sans moi',1985);

insert into INTERPRETE values (13,34,2);
insert into INTERPRETE values (13,29,2);

---------------------------------------------------------------------
-- alain chamfort (reference = 3)
insert into DISQUE values (15,'neuf',1993,1);
insert into DISQUE values (16,'trouble',1990,1);

insert into CHANSON values (35,'personne n''aime personne',1990);
insert into CHANSON values (36,'l''ennemi dans la glace',1993);
insert into CHANSON values (37,'la femme de ma vie',1990);
insert into CHANSON values (38,'mens',1993);

insert into INTERPRETE values (15,36,3);
insert into INTERPRETE values (15,38,3);

insert into INTERPRETE values (16,35,3);
insert into INTERPRETE values (16,37,3);

---------------------------------------------------------------------
-- les innocents (reference = 5)
insert into DISQUE values (17,'fous a lier',1991,1);

insert into CHANSON values (39,'un homme extraordinaire',1991);
insert into CHANSON values (45,'fous a lier',1991);
insert into CHANSON values (41,'l''autre finistere',1991);
insert into CHANSON values (43,'mon dernier soldat',1991);

insert into INTERPRETE values (17,39,5);
insert into INTERPRETE values (17,45,5);
insert into INTERPRETE values (17,41,5);
insert into INTERPRETE values (17,43,5);

---------------------------------------------------------------------
-- mc solar (reference = 11)
insert into DISQUE values (18,'qui seme le vent rec',1991,4);

insert into CHANSON values (40,'qui seme le vent recolte le te',1991);
insert into CHANSON values (42,'victime de la mode',1991);
insert into CHANSON values (44,'caroline',1991);
insert into CHANSON values (46,'bouge de la',1991);
insert into CHANSON values (47,'a temps partiel',1991);

insert into INTERPRETE values (18,40,11);
insert into INTERPRETE values (18,42,11);
insert into INTERPRETE values (18,44,11);
insert into INTERPRETE values (18,46,11);
insert into INTERPRETE values (18,47,11);

---------------------------------------------------------------------
-- album "sol en si" 1997

insert into CHANTEUR values (12,'fauque','jean');
insert into CHANTEUR values (13,'les valentins',null);
insert into CHANTEUR values (14,'zazie',null);
insert into CHANTEUR values (15,'le forestier','maxime');
insert into CHANTEUR values (16,'jonasz','michel');
insert into CHANTEUR values (17,'cabrel','francis');

insert into DISQUE values (19,'sol en si',1997,1);
insert into CHANSON values (48,'jolie louise',null);

insert into INTERPRETE values (19,30,14);
insert into INTERPRETE values (19,30,15);
insert into INTERPRETE values (19,48,15);
insert into INTERPRETE values (19,48,2);
insert into INTERPRETE values (19,48,17);