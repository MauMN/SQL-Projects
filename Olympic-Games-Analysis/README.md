<h1>Olympic Games Analysis with SQL and Tableau</h1>
<p>The main objective of this project is to extract information about the performance of different countries and competitors in the olympic games, using a 
    <a href="https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results">Kaggle dataset</a>
    containing data for games held through 120 years of history, loaded locally in a PostgreSQL relational database. We will answer several relevant questions using
    SQL queries and visualize the data using Tableau Public. 
</p>

<h2>The tables</h2>
<p>The dataset contains two tables, olympics_games cointaining the majority of the data, and regions, wich contains the country name and the
    3 letter code of it (noc column):</p>
<img src="https://i.imgur.com/edyz0o1.png">
<br>
<img src="https://i.imgur.com/Jqj0vYT.png">

<h2>The questions</h2>

<p>
We will answer different types of questions (all of them are listed in the 'olympics queries.sql' with the respectives sql queries)
about the data regarding countries and competitors such as the following:
</p>

<h3>5. Which nation has participated in all of the olympic games?</h3>

<img src="https://i.imgur.com/yBBbqWN.png">

<h3>9. Who are the oldest athletes to win a gold medal?</h3>

<img src="https://i.imgur.com/dK8Lpbx.png">

<h3>19. In which Sport/event, Argentina has won highest medals?</h3>

<img src="https://i.imgur.com/4hsBFsD.png">

<h2>The dashboard</h2>

<p>To visualize the information we used a Tableau Public dashboard. Given that the free version of Tableau does not offer a direct database connection, we exported the 
    information obtain with the 'select query for export.sql' as a .xlsx file and then loaded it into Tableau and performed some calculations there, 
    resulting in the following dashboard (the screenshot contains the link to the Tableau Public interactive dashboard):
</p>

<a href="https://public.tableau.com/app/profile/mauro.navarra/viz/Olympicgamesanalysis/Dashboard1"><img src="https://i.imgur.com/DRKqVEu.jpeg"></a>

<br>
<br>
<br>

<p>Alternatively, a PowerBI dashboard was also created in PowerBI Desktop, but in this case we do not have an interactive online dashboard option for free users:</p>
<img src="https://i.imgur.com/ZQh93Ry.png">