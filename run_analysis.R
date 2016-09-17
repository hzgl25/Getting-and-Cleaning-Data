if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Labels
act_labels <- read.table("./Working Directory/UCI HAR Dataset/activity_labels.txt")[,2]

# Column names
features <- read.table("./Working Directory/UCI HAR Dataset/features.txt")[,2]

# Extract the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

# Load/process X_test & y_test data.
X_test <- read.table("./Working Directory/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./Working Directory/UCI HAR Dataset/test/y_test.txt")
sub_test <- read.table("./Working Directory/UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

# Extract the mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

# Load activity labels
y_test[,2] = act_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(sub_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(sub_test), y_test, X_test)

# Load and process X_training & y_training data.
X_training <- read.table("./Working Directory/UCI HAR Dataset/train/X_train.txt")
y_training <- read.table("./Working Directory/UCI HAR Dataset/train/y_train.txt")

sub_training <- read.table("./Working Directory/UCI HAR Dataset/train/subject_train.txt")

names(X_training) = features

# Extract the mean and standard deviation for each measurement.
X_training = X_training[,extract_features]

# Load activity data
y_training[,2] = act_labels[y_training[,1]]
names(y_training) = c("Activity_ID", "Activity_Label")
names(sub_training) = "subject"

# Bind data
training_data <- cbind(as.data.table(sub_training), y_training, X_training)

# Merge test and training data
data = rbind(test_data, training_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")

