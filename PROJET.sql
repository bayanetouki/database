-- Création de la base
DROP DATABASE IF EXISTS PROJET;
CREATE DATABASE PROJET;
USE PROJET;

-- Table Hotel
CREATE TABLE Hotel (
    Id_Hotel INT PRIMARY KEY,
    Ville VARCHAR(30),
    Pays VARCHAR(30),
    Code_Postal INT
);

-- Table type de chambre
CREATE TABLE Type_Chambre (
    Id_Type INT PRIMARY KEY,
    Type VARCHAR(30),
    Tarif FLOAT
);

-- Table Chambre
CREATE TABLE Chambre (
    Id_Chambre INT PRIMARY KEY,
    Numero INT,
    Etage INT,
    Fumeurs BOOLEAN,
    Id_Hotel INT,
    Id_Type INT,
    FOREIGN KEY (Id_Hotel) REFERENCES Hotel(Id_Hotel),
    FOREIGN KEY (Id_Type) REFERENCES Type_Chambre(Id_Type)
);

-- Table Prestation
CREATE TABLE Prestation (
    Id_Prestation INT PRIMARY KEY,
    Prix INT,
    Description TEXT
);

-- Table Offre (relation N-N entre Hotel et Prestation)
CREATE TABLE Offre (
    Id_Hotel INT,
    Id_Prestation INT,
    PRIMARY KEY (Id_Hotel, Id_Prestation),
    FOREIGN KEY (Id_Hotel) REFERENCES Hotel(Id_Hotel),
    FOREIGN KEY (Id_Prestation) REFERENCES Prestation(Id_Prestation)
);

-- Table Client
CREATE TABLE Client (
    Id_Client INT PRIMARY KEY,  
    Adresse VARCHAR(40),
    Ville VARCHAR(30),
    Code_Postal VARCHAR(30),
    E_mail VARCHAR(30),
    Num_Tele VARCHAR(15),
    Nom_Complet VARCHAR(40)
);


-- Table Evaluation
CREATE TABLE Evaluation (
    Id_Evaluation INT PRIMARY KEY,
    Date_Arrivee DATE,
    Note INT,
    Commentaire VARCHAR(100),
    Id_Hotel INT,
    Id_Client INT,
    FOREIGN KEY (Id_Hotel) REFERENCES Hotel(Id_Hotel),
    FOREIGN KEY (Id_Client) REFERENCES Client(Id_Client)
);

-- Table Reservation avec Id_Chambre
CREATE TABLE Reservation (
    Id_Reservation INT PRIMARY KEY,
    Date_Arrivee DATE,
    Date_Depart DATE,
    Id_Client INT,
    Id_Chambre INT,
    FOREIGN KEY (Id_Client) REFERENCES Client(Id_Client),
    FOREIGN KEY (Id_Chambre) REFERENCES Chambre(Id_Chambre)
);

-- Table Concerner (N-N entre Reservation et Prestation)
CREATE TABLE Concerner (
    Id_Prestation INT,
    Id_Reservation INT,
    PRIMARY KEY (Id_Prestation, Id_Reservation),
    FOREIGN KEY (Id_Prestation) REFERENCES Prestation(Id_Prestation),
    FOREIGN KEY (Id_Reservation) REFERENCES Reservation(Id_Reservation)
);
-- Hôtels
INSERT INTO Hotel VALUES
(1, 'Paris', 'France', 75001),
(2, 'Lyon', 'France', 69002);

-- Clients
INSERT INTO Client (
    Id_Client, Adresse, Ville, Code_Postal, E_mail, Num_Tele, Nom_Complet
) VALUES
(1, '12 Rue de Paris', 'Paris', '75001', 'jean.dupont@email.fr', '0612345678', 'Jean Dupont'),
(2, '5 Avenue Victor Hugo', 'Lyon', '69002', 'marie.leroy@email.fr', '0623456789', 'Marie Leroy'),
(3, '8 Boulevard Saint-Michel', 'Marseille', '13005', 'paul.moreau@email.fr', '0634567890', 'Paul Moreau'),
(4, '27 Rue Nationale', 'Lille', '59800', 'lucie.martin@email.fr', '0645678901', 'Lucie Martin'),
(5, '3 Rue des Fleurs', 'Nice', '06000', 'emma.giraud@email.fr', '0656789012', 'Emma Giraud');


-- Prestations
INSERT INTO Prestation VALUES
(1, 15, 'Petit-déjeuner'),
(2, 30, 'Navette aéroport'),
(3, 0, 'Wi-Fi gratuit'),
(4, 50, 'Spa et bien-être'),
(5, 20, 'Parking sécurisé');

-- Type de chambre
INSERT INTO Type_Chambre VALUES
(1, 'Simple', 80),
(2, 'Double', 120);

-- Chambres
INSERT INTO Chambre VALUES
(1, 201, 2, 0, 1, 1),
(2, 502, 5, 1, 1, 2),
(3, 305, 3, 0, 2, 1),
(4, 410, 4, 0, 2, 2),
(5, 104, 1, 1, 2, 2),
(6, 202, 2, 0, 1, 1),
(7, 307, 3, 1, 1, 2),
(8, 101, 1, 0, 1, 1);

-- Réservations avec Id_Chambre
INSERT INTO Reservation VALUES
(1, '2025-06-15', '2025-06-18', 1, 1),
(2, '2025-07-01', '2025-07-05', 2, 2),
(3, '2025-08-10', '2025-08-14', 3, 3),
(4, '2025-09-05', '2025-09-07', 4, 4),
(5, '2025-09-20', '2025-09-25', 5, 5),
(7, '2025-11-12', '2025-11-14', 2, 7),
(9, '2026-01-15', '2026-01-18', 4, 8),
(10, '2026-02-01', '2026-02-05', 2, 6);

-- Evaluations
INSERT INTO Evaluation VALUES
(1, '2025-06-15', 5, 'Excellent séjour, personnel très accueillant.', 1, 1),
(2, '2025-07-01', 4, 'Chambre propre, bon rapport qualité/prix.', 1, 2),
(3, '2025-08-10', 3, 'Séjour correct mais bruyant la nuit.', 2, 3),
(4, '2025-09-05', 5, 'Service impeccable, je recommande.', 2, 4),
(5, '2025-09-20', 4, 'Très bon petit-déjeuner, hôtel bien situé.', 2, 5);

-- Offre (hôtel → prestation)
INSERT INTO Offre VALUES 
(1, 1), (1, 3), 
(2, 1), (2, 2), (2, 3), (2, 5);

-- Concerner (réservation → prestation)
INSERT INTO Concerner VALUES 
(1, 1), (3, 1),
(1, 2), (5, 2),
(3, 3),
(1, 4), (2, 4), (4, 4),
(1, 5);
-- A. Liste des réservations avec nom du client et ville de l’hôtel
SELECT 
    R.Id_Reservation,
    C.Nom_Complet,
    H.Ville
FROM Reservation R
JOIN Client C ON R.Id_Client = C.Id_Client
JOIN Chambre Ch ON R.Id_Chambre = Ch.Id_Chambre
JOIN Hotel H ON Ch.Id_Hotel = H.Id_Hotel;

-- B. Clients qui habitent à Paris
SELECT * FROM Client WHERE Ville = 'Paris';

-- C. Nombre de réservations par client
SELECT 
    C.Id_Client, 
    C.Nom_Complet, 
    COUNT(R.Id_Reservation) AS Nb_Reservations
FROM Client C
LEFT JOIN Reservation R ON C.Id_Client = R.Id_Client
GROUP BY C.Id_Client, C.Nom_Complet;

-- D. Nombre de chambres pour chaque type de chambre
SELECT 
    T.Type,
    COUNT(Ch.Id_Chambre) AS Nb_Chambres
FROM Type_Chambre T
LEFT JOIN Chambre Ch ON T.Id_Type = Ch.Id_Type
GROUP BY T.Type;

-- E. Chambres non réservées entre deux dates données
SELECT * 
FROM Chambre Ch
WHERE NOT EXISTS (
    SELECT 1
    FROM Reservation R
    WHERE R.Id_Chambre = Ch.Id_Chambre
    AND R.Date_Arrivee < @date_fin 
    AND R.Date_Depart > @date_debut
);
