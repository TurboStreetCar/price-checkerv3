import streamlit as st
#st.set_page_config(layout="wide")
# Define the pages pointing to the files in the pages folder
oil_prices = st.Page("pages/Oil_Prices.py", title="Oil Prices", icon="🏠", default=True)
weather = st.Page("pages/Weather_Conditions.py", title="Weather Conditions", icon="🌤️")

# Initialize and run navigation
pg = st.navigation([oil_prices, weather])
pg.run()
