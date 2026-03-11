import streamlit as st
import pandas as pd
import altair as alt
from sqlalchemy import create_engine, text
from datetime import date, timedelta

st.title("Fuel Oil Price History")

# 1. Calculate dynamic defaults
today = date.today()
one_month_ago = today - timedelta(days=30)

# 2. Sidebar Date Selectors with dynamic defaults
st.sidebar.header("Date Range")
start_date = st.sidebar.date_input("Start Date", one_month_ago)
end_date = st.sidebar.date_input("End Date", today)

def get_data(start, end):
    user = "db_user"
    password = "db_pass"
    host = "10.200.100.3"
    port = 8307
    database = "pricing"

    engine = create_engine(f"mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}")
    
    # Use text() for parameterized query
    query = text("""
        SELECT Date, Time, Price 
        FROM Price 
        WHERE Date BETWEEN :start AND :end
        ORDER BY Date ASC, Time ASC
    """)
    
    # Execute with params
    df = pd.read_sql(query, engine, params={"start": start, "end": end})
    return df

try:
    # Fetch data based on sidebar selection
    df = get_data(start_date, end_date)

    if not df.empty:
        # 1. Handle Timestamp calculation
        df['Timestamp'] = pd.to_datetime(df['Date']) + pd.to_timedelta(df['Time'].astype(str))
        
        # 2. Calculate dynamic axis limits with 0.2 padding
        y_min = float(df['Price'].min()) - 0.05
        y_max = float(df['Price'].max()) + 0.05
        
        # 3. Define the Chart with specific axis formatting
        chart = alt.Chart(df).mark_line(point=True).encode(
            x=alt.X('Timestamp:T', 
                title='Date & Time',
                axis=alt.Axis(format='%b %d, %H:%M') # Format: "Mar 07, 15:49"
            ),
            y=alt.Y('Price:Q', title='Price', scale=alt.Scale(domain=[y_min, y_max])),
            tooltip=[alt.Tooltip('Timestamp:T', format='%Y-%m-%d %H:%M:%S'), 'Price']
        ).interactive()
    
        st.altair_chart(chart, use_container_width=True)
        
        st.subheader(f"Price History: {start_date} to {end_date}")
    
        # 4. Clean up the table for display
        # We create a display version so we don't break the chart's data types
        display_df = df.copy()
        display_df['Time'] = display_df['Timestamp'].dt.strftime('%H:%M:%S')
        st.write(display_df[['Date', 'Time', 'Price']])
    else:
        st.warning(f"No data found between {start_date} and {end_date}.")

except Exception as e:
    st.error(f"Error: {e}")
