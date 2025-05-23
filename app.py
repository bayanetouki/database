import streamlit as st
import sqlite3
import pandas as pd
from datetime import date

# Connexion à la base de données
def get_connection():
    return sqlite3.connect("hotel.db")

# 1. Liste des clients
def afficher_clients():
    conn = get_connection()
    df = pd.read_sql_query("SELECT * FROM Client", conn)
    conn.close()
    return df

# 2. Liste des réservations
def afficher_reservations():
    conn = get_connection()
    df = pd.read_sql_query("""
        SELECT R.Id_Reservation, C.Nom_Complet, Ch.Numero AS Chambre,
               R.Date_Arrivee, R.Date_Depart
        FROM Reservation R
        JOIN Client C ON R.Id_Client = C.Id_Client
        JOIN Chambre Ch ON R.Id_Chambre = Ch.Id_Chambre
    """, conn)
    conn.close()
    return df

# 3. Chambres disponibles
def chambres_disponibles(date_debut, date_fin):
    conn = get_connection()
    query = """
        SELECT * FROM Chambre
        WHERE Id_Chambre NOT IN (
            SELECT Id_Chambre FROM Reservation
            WHERE Date_Arrivee < ? AND Date_Depart > ?
        )
    """
    df = pd.read_sql_query(query, conn, params=(date_fin, date_debut))
    conn.close()
    return df

# 4. Ajouter un client
def ajouter_client(nom, adresse, ville, code_postal, email, tel):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Client (Adresse, Ville, Code_Postal, E_mail, Num_Tele, Nom_Complet)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (adresse, ville, code_postal, email, tel, nom))
    conn.commit()
    conn.close()

# 5. Ajouter une réservation
def ajouter_reservation(id_client, id_chambre, date_arrivee, date_depart):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Reservation (Id_Client, Id_Chambre, Date_Arrivee, Date_Depart)
        VALUES (?, ?, ?, ?)
    """, (id_client, id_chambre, date_arrivee, date_depart))
    conn.commit()
    conn.close()

# Fonctions sécurisées de formatage
def format_nom_client(client_id):
    match = clients[clients["Id_Client"] == client_id]
    return match.iloc[0]["Nom_Complet"] if not match.empty else str(client_id)

def format_numero_chambre(chambre_id):
    match = chambres[chambres["Id_Chambre"] == chambre_id]
    return f"Chambre {match.iloc[0]['Numero']}" if not match.empty else str(chambre_id)

# Configuration Streamlit
st.set_page_config(page_title="Gestion Hôtel", layout="wide")
st.title("🏨 Gestion de l'Hôtel")

# Onglets
onglets = st.tabs([
    "🏠 Accueil",
    "📋 Réservations",
    "👥 Clients",
    "📆 Disponibilité",
    "➕ Ajouter Client",
    "📝 Ajouter Réservation"
])

with onglets[0]:
    st.subheader("Bienvenue sur le tableau de bord de gestion de l'hôtel.")
    st.markdown("Utilisez les onglets ci-dessus pour accéder aux différentes fonctionnalités.")

with onglets[1]:
    st.subheader("📋 Liste des Réservations")
    st.dataframe(afficher_reservations())

with onglets[2]:
    st.subheader("👥 Liste des Clients")
    st.dataframe(afficher_clients())

with onglets[3]:
    st.subheader("📆 Vérifier la disponibilité des chambres")
    col1, col2 = st.columns(2)
    with col1:
        date_debut = st.date_input("Date d'arrivée", date.today())
    with col2:
        date_fin = st.date_input("Date de départ", date.today())

    if date_fin <= date_debut:
        st.warning("⚠️ La date de départ doit être après la date d'arrivée.")
    else:
        dispo = chambres_disponibles(date_debut.isoformat(), date_fin.isoformat())
        st.dataframe(dispo)

with onglets[4]:
    st.subheader("➕ Ajouter un Client")
    with st.form("form_client"):
        nom = st.text_input("Nom complet")
        adresse = st.text_input("Adresse")
        ville = st.text_input("Ville")
        code_postal = st.text_input("Code postal")
        email = st.text_input("Email")
        tel = st.text_input("Téléphone")
        submit = st.form_submit_button("Enregistrer le client")

        if submit:
            if all([nom, adresse, ville, code_postal, email, tel]):
                ajouter_client(nom, adresse, ville, code_postal, email, tel)
                st.success("✅ Client ajouté avec succès.")
            else:
                st.warning("⚠️ Veuillez remplir tous les champs.")

with onglets[5]:
    st.subheader("📝 Ajouter une Réservation")
    conn = get_connection()
    clients = pd.read_sql_query("SELECT Id_Client, Nom_Complet FROM Client", conn)
    chambres = pd.read_sql_query("SELECT Id_Chambre, Numero FROM Chambre", conn)
    conn.close()

    client_ids = clients["Id_Client"].tolist()
    chambre_ids = chambres["Id_Chambre"].tolist()

    id_client = st.selectbox("Client", client_ids, format_func=format_nom_client)
    id_chambre = st.selectbox("Chambre", chambre_ids, format_func=format_numero_chambre)

    date_arrivee = st.date_input("Date d'arrivée (réservation)", date.today())
    date_depart = st.date_input("Date de départ (réservation)", date.today())

    if st.button("Ajouter Réservation"):
        if date_depart > date_arrivee:
            ajouter_reservation(id_client, id_chambre, date_arrivee.isoformat(), date_depart.isoformat())
            st.success("✅ Réservation enregistrée avec succès.")
        else:
            st.warning("⚠️ La date de départ doit être après la date d’arrivée.")
