# ARIMA-information-in-stock-market

This project is about testing the Efficient Market Hypothesis by Eugene Fama.
Stock price regression model with and without variable ‘information’ is compared through Python and R code. Data from 4 companies are used. 
Stock price data were collected through Investing.com

Berkshire Hathaway: representing firms that are prospected to have low volatility due to information changes.
 Nvidia: representing the technology sector with low volatility.
Tesla: representing firms that are prospected to have high volatility due to information changes.
Google: representing the technology sector with low volatility due to information changes.

Because the technology sector tends to be considered the most information-sensitive area,
the project focused on the technology sector to magnify the impact of the regression model with the ‘information’ variable.

Information variable states the impact of newly released information on the stock market.
Can refer to any form of information, but due to technical problems the project limited the information variable to news.
More specifically, news from the Financial Times. (Originally targeting The Economists, but due to an HTML form update in their page, the code were changed for Financial Times)

Based on the program and dataset provided as an example, the model stated that the ARIMA model with information variable is slightly better at predicting 
price of stock both in the long term and short term.

Despite the fact that this project deals with quite interesting subject, there must be an acknowledgement about the limitations of the project.
1. In Python code of 1-1, 'Vader' was used to analyze the sentiments of each article. The accuracy is questionable, and the best way is to create
   an independent machine learning model and training for financial sentiment analysis. However, it was not possible due to my limitations of programming skills.
2. In the Python code of 1-1, sentiment has a range of +-1. However, the data was not scaled appropriately for the stock price data. Therefore, there exists a high
   possibility for the impact of sentiment data is underestimated.
3. In the R code of 2, the ARIMA model is created relying on the 'auto.arima' function due to limitations of my mathematical knowledge. Therefore there exists a possibility
   of the ARIMA model differencing process was inappropriate.
4. Overall, the number of companies and the size of data used in the project is too small. A bigger volume of data is needed for higher statistical significance.
5. Articles from Finantial Times are not the only information available in the market. Nearly infinite source of information exists.
6. Multiplier for each daily sentiment based on the importance of the information can improve the significance of the study.


1-1  This Code extracts the sentiment for selected company by each articles.
Sentiment data may vary for -1(maximum negativity) to +1(maximum positivity)
base_url --> Here you copy and past the page you first see after entering [The name of a company you want to analyze] at Financial Times home page.
num_pages --> Here you enter the amout of page you want to analyse shown at Financial Times web page.
Sentiment data files would be extracted with a name of [sentiment_analysis_Apple.csv]. You can hange the name for each company.
*Be aware of encoding type* If any error is detected, this might be the place you want to first look at.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
import requests
from bs4 import BeautifulSoup
from nltk.sentiment.vader import SentimentIntensityAnalyzer
import pandas as pd

def analyze_sentiment(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')

    articles = soup.select('.o-teaser__heading a')

    analyzer = SentimentIntensityAnalyzer()

    results = []
    for article in articles:
        # Extracting the date
        date_element = article.find_previous(class_='stream-card__date')
        date = date_element.find('time')['datetime']

        # Extracting the year, month, and day from the date
        year, month, day = date.split('T')[0].split('-')

        # Extracting the news title
        title = article.get_text()

        # Extracting the news summary if it exists
        summary_element = article.find_next(class_='o-teaser__standfirst')
        summary = summary_element.find('a').get_text() if summary_element else ''

        # Analyzing sentiment using nltk's SentimentIntensityAnalyzer
        sentiment_scores = analyzer.polarity_scores(title + ', ' + summary)
        sentiment = sentiment_scores['compound']

        results.append({'Year': year, 'Month': month, 'Day': day, 'Title': title, 'Summary': summary, 'Sentiment': sentiment})

    return results

base_url = 'https://www.ft.com/stream/a39a4558-f562-4dca-8774-000246e6eebe?page='
num_pages = 30

all_results = []
for page in range(1, num_pages + 1):
    url = base_url + str(page)
    results = analyze_sentiment(url)
    all_results.extend(results)
    print(f"Page {page} processed")

df = pd.DataFrame(all_results)
df.to_csv('sentiment_analysis_Apple.csv', encoding='utf-8-sig', index=False)

print('CSV ready')
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


1-2  For any company, multiple articles can be published in a single day. 
This code will merge the total sentiment for each day and simplify the files.
If no article was published, the day will have a sentiment of 0.
Change the file name for each company.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
import csv
from collections import defaultdict
from datetime import datetime

# Define the path for the input CSV file
input_csv_file = 'sentiment_analysis_Apple.csv'

# Create a dictionary to store the sum of sentiment per date
sentiment_sum = defaultdict(float)

# Read the input CSV file and calculate the sum of sentiment for each date
with open(input_csv_file, 'r', encoding='utf-8-sig') as input_file:
    reader = csv.reader(input_file)
    next(reader)  # Skip the header row if it exists

    for row in reader:
        year = int(row[0])
        month = int(row[1])
        day = int(row[2])
        date = datetime(year, month, day).date()
        title = row[3]
        summary = row[4]
        sentiment = float(row[5])

        if date >= datetime.strptime('2019-05-01', '%Y-%m-%d').date() and date <= datetime.strptime('2023-05-01', '%Y-%m-%d').date():
            sentiment_sum[date] += sentiment

# Create a new CSV file for the output
output_csv_file = 'output_sentiment_sum_Apple.csv'
with open(output_csv_file, 'w', newline='', encoding='utf-8-sig') as output_file:
    writer = csv.writer(output_file)
    writer.writerow(['Date', 'SentimentSum'])  # Write the header row

    for date, sentiment in sentiment_sum.items():
        writer.writerow([date, sentiment])

print(f"Output CSV file created: {output_csv_file}")
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


1-3  This is a code for merging stock price data with sentiment data. If you are familiar with excel programs, You can merge them on your own.
However, the excel data form should be the same as the data that I contained as an example to run the R code later.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
import csv
from datetime import datetime

# Read data from file A
data_A = []
with open('AAPL Historical Data.csv', 'r', encoding='utf-8-sig') as file_A:
    reader_A = csv.DictReader(file_A)
    for row in reader_A:
        date_str = row['Date']
        date = datetime.strptime(date_str, '%m/%d/%Y').strftime('%Y-%m-%d')
        row['Date'] = date
        data_A.append(row)

# Read data from file B and store sentiment sum values in a dictionary
data_B = {}
with open('output_sentiment_sum_Apple.csv', 'r', encoding='utf-8-sig') as file_B:
    reader_B = csv.DictReader(file_B)
    for row in reader_B:
        date_str = row['Date']
        sentiment_sum = float(row['SentimentSum'])
        data_B[date_str] = sentiment_sum

# Update data in file A with sentiment sum values from file B
for row in data_A:
    date = row['Date']
    if date in data_B:
        row['SentimentSum'] = data_B[date]
    else:
        row['SentimentSum'] = 0

# Write updated data to a new CSV file
fieldnames = data_A[0].keys()
with open('output_merged_Apple.csv', 'w', newline='', encoding='utf-8-sig') as merged_file:
    writer = csv.DictWriter(merged_file, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(data_A)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


2  This is the R code used to create the ARIMA (Autoregressive Integrated Moving average Model) model with information variables included and excluded. 
The explanation and function for each segment are annotated as '#'. You may customize it in a way you want.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load required libraries
library(forecast)
library(ggplot2)
library(dplyr)
# Read the CSV file
data <- read.csv("C:/Users/taeho/OneDrive/바탕 화면/학술제/merged change%andsentiment for regression/output_merged_Nvidia.csv")

# Convert Date column to date type
data$Date <- as.Date(data$Date)

# Convert Change% column to numeric
data$Change1 <- as.numeric(gsub("%", "", data$Change, fixed = TRUE))

# Convert SentimentSum column to numeric
data$SentimentSum <- as.numeric(data$SentimentSum)

# Convert Price column to numeric
data$Price <- as.numeric(data$Price)

# Reverse the order of rows
data <- arrange(data, Date)


# Split the data into train and test sets (80% train, 20% test)
train_size <- round(0.7 * nrow(data))
train <- data[1:train_size, ]
test <- data[(train_size + 1):nrow(data), ]

# Create ARIMA model using Price, SentimentSum, and Change%
model1 <- auto.arima(train$Price, xreg = as.matrix(train[, c("SentimentSum", "Change1")], ncol = 2))

# Create ARIMA model using only Price
model2 <- auto.arima(train$Price)

# Forecast using model1 and model2
forecast1 <- forecast(model1, h = nrow(test), xreg = as.matrix(test[, c("SentimentSum", "Change1")], ncol = 2))
forecast2 <- forecast(model2, h = nrow(test))


# Plotting the test data and forecasts within the range of test data
ggplot(data = test) +
  geom_line(aes(x = Date, y = Price, color = "Test"), linetype = "solid", size = 1, alpha = 0.8) +
  geom_line(aes(x = Date, y = forecast1$mean, color = "ARIMA-GB"), linetype = "solid", size = 1, alpha = 0.8) +
  geom_line(aes(x = Date, y = forecast2$mean, color = "ARIMA"), linetype = "solid", size = 1, alpha = 0.8) +
  xlab("Date-Month/Year") +
  ylab("Price-$") +
  labs(title = "ARIMA / ARIMA-GB Forecast - Nvidia") +
  theme_minimal() +
  coord_cartesian(xlim = c(min(test$Date), max(test$Date))) +
  scale_color_manual(values = c("Test" = "black", "ARIMA-GB" = "blue", "ARIMA" = "red"), labels = c("ARIMA", "ARIMA-GB", "Test")) +
  theme(legend.position = "top")



# Calculate RMSE for model1 and model2
rmse1 <- sqrt(mean((forecast1$mean - test$Price)^2))
rmse2 <- sqrt(mean((forecast2$mean - test$Price)^2))

# Calculate MAE for model1 and model2
mae1 <- mean(abs(forecast1$mean - test$Price))
mae2 <- mean(abs(forecast2$mean - test$Price))

rm(list=ls())





# Set date range to compare (n of days)
forecast1_subset <- head(forecast1$mean, 45)
forecast2_subset <- head(forecast2$mean, 45)
test_subset <- head(test$Price, 45)
date_subset <- head(test$Date, 45)

# Plotting the subset of test data and forecasts
ggplot() +
  geom_line(data = data.frame(Date = date_subset, Price = test_subset), aes(x = Date, y = Price), color = "black", linetype = "solid", size = 1, alpha = 0.8) +
  geom_line(data = data.frame(Date = date_subset, Price = forecast1_subset), aes(x = Date, y = forecast1_subset), color = "blue", linetype = "solid", size = 1, alpha = 0.8) +
  geom_line(data = data.frame(Date = date_subset, Price = forecast2_subset), aes(x = Date, y = forecast2_subset), color = "red", linetype = "solid", size = 1, alpha = 0.8) +
  xlab("Date-Month/Day") +
  ylab("Price-$") +
  labs(title = "ARIMA / ARIMA-GB Forecast - Nvidia (First 45 Values)") +
  theme_minimal() +
  coord_cartesian(xlim = c(min(date_subset), max(date_subset))) +
  scale_color_manual(values = c("black", "blue", "red"), labels = c("ARIMA", "ARIMA-GB", "Test")) +
  theme(legend.position = "top")

# Calculate RMSE for the first 30 values of model1 and model2
rmse1_subset <- sqrt(mean((forecast1_subset - test_subset)^2))
rmse2_subset <- sqrt(mean((forecast2_subset - test_subset)^2))

# Calculate MAE for the first 30 values of model1 and model2
mae1_subset <- mean(abs(forecast1_subset - test_subset))
mae2_subset <- mean(abs(forecast2_subset - test_subset))
-------------------------------------------------------------------------------------------------------------------------------------------------------------------



