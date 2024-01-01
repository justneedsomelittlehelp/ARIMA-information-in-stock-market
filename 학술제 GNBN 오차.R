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





# Subset the first 30 values for the forecasts and test data
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

