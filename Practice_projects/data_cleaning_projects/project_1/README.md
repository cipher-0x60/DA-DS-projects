# Project-1 Subscription Data Cleaning and Analysis Excel  @Last Saturday

# Subscription Data Cleaning and Analysis Excel October 3, 2026

### Business domain

**Subscription Growth & Revenue Intelligence**

Industry: SaaS / Subscription business

**Business situation**

A subscription company operating across several European markets is experiencing uncertainty about its revenue performance and customer retention.

Management wants to understand:

- How many customers are actively subscribed?
- How much recurring revenue is the company generating?
- Are customers cancelling their subscriptions at an increasing rate?
- Which plans and markets contribute to revenue?
- Are billing records reliable enough to support financial decisions?
- Where should the company focus its retention and growth efforts?

### Role

> Data Analyst
> 

### Business objective

Management wants an interactive report that answers:

> Understand recurring revenue, Investigate customer retention and churn, Evaluate market and plan performance, Improve subscription data reliability
> 

### Business Problem

> Management does not have a trustworthy view of recurring revenue across plans and markets.The company needs to understand how many customers are leaving and how its subscription base is changing. Management wants to understand differences between the company's European markets and subscription offerings. Inconsistent and potentially incorrect subscription records undermine the reliability of company reporting.
> 

### Decisions the report should support / Business Problem

- [ ]  What is the monthly recurring revenue (MRR) from active paid subscriptions?
- [ ]  Which plans generate the most revenue?
- [ ]  How is revenue distributed across countries?
- [ ]  Are there unusually high or negative subscription prices?
- [ ]  How many subscriptions are active, paused, and cancelled?
- [ ]  What is the cancellation rate for a defined period?
- [ ]  How long do customers typically remain subscribed?
- [ ]  Which plans or markets show higher cancellation rates?
- [ ]  How many active customers are in each country?
- [ ]  What is the average subscription price by plan and country?
- [ ]  Which markets have the highest cancellation proportions?
- [ ]  Are some countries more dependent on free subscriptions?
- [ ]  How many records contain invalid or suspicious values?
- [ ]  Which records violate the expected subscription lifecycle?
- [ ]  Are duplicate IDs genuine duplicate transactions or separate billing events?
- [ ]  How much could the identified data-quality problems affect reported revenue and churn?

### Checklist

### Data Profiling ✅

- [x]  **Number of tables/files**
    
    1 tables → subscriptio_raw
    
- [x]  **Number of rows**
    
    163
    
- [x]  **Number of columns**
    
    12
    
- [x]  **Column names**
    
    ```html
    subscription_id
    customer_id
    customer_email
    country
    plan
    monthly_price
    status
    start_date
    end_date
    payment_method
    updated_at
    internal_notes
    ```
    
- [x]  **Data type**
    
    Data types are not defined need to correct the data types
    
- [x]  **Missing values**
    - [x]  email ⇒ missing values 3%
    - [x]  start date ⇒ missing values 9%
    - [x]  end date ⇒ missing values 69%
    - [x]  payment_metthod ⇒ missinig values 6%
- [x]  **Duplicate records**
    - [x]  subscription_id ⇒ 138 unique / 150
    - [x]  customer_id ⇒ 136 unique / 149
    - [x]  customer_id ⇒ 137 unique / 148
    - [x]  plan ⇒ 2 unique / 13
    - [x]  monthly_price ⇒ 1 unique / 7
    - [x]  status 1 unique / 14
    - [x]  suspicious column start_date
    - [x]  end_date ⇒ 33 unique / 39
    - [x]  payment _method 0 unique /6
    - [x]  updated_at ⇒ 148 unique / 155
- [x]  **Unique IDs**
    - [x]  subscription_id ⇒ But containing the duplicates
- [x]  **Date fields**
    - [x]  start_date
    - [x]  end_date
    - [x]  updated_at
- [x]  **Numeric fields**
    - [x]  not presented
- [x]  **Categorical fields**
    - [x]  customer_id
    - [x]  country
    - [x]  plan
    - [x]  monthly_price
    - [x]  status
    - [x]  payment_method
- [x]  **Potential primary keys**
    - [x]  not presented
- [x]  **Potential foreign keys**
    - [x]  not presented
- [x]  **Suspicious values**
    - [x]  monthly_price
    - [x]  start_date

### Data cleaning✅

- [x]  Remove unnecessary columns
    - [x]  internal_notes
- [x]  Rename columns
    - [x]  not needed
- [x]  Correct data types
    - [x]  monthly_price - decimal⇒currency
    - [x]  start_date- num⇒datetime
- [x]  Handle missing / blank values
    - [x]  email ⇒ missing values 3%
        - [x]  Replace with unknown
    - [x]  start date ⇒ missing values 9%
        - [x]  Remained null
    - [x]  end date ⇒ missing values 69%
        - [x]  Remained null
    - [x]  payment_metthod ⇒ missinig values 6%
        - [x]  Replaced N/A, Null, null with Unknown
- [x]  Removed Dummy or Test Data Rows
    - [x]  customer_email ⇒ test emails removed using the column filter
- [x]  Remove duplicates where appropriate
    - [x]  not needed
- [x]  Trim text
- [x]  Clean text
- [x]  Standardize categories
    - [x]  Fix the naming convention
        - [x]  country
        - [x]  plan
        - [x]  status
        - [x]  payment-method
        - [x]  monthly-price
            - [x]  fix the pricing convension
- [x]  Standardize dates
- [x]  Standardize IDs
- [x]  Replace invalid values
- [x]  Filter invalid records

### Data Transformation✅

- [x]  Split columns where necessary
    - [x]  Not Needed
- [x]  Extract text
    - [x]  Not Needed
- [x]  Add conditional columns
    - [x]  created the column of customer_name from customer_email
- [x]  Add calculated columns where appropriate
    - [x]  Not Needed
- [x]  Create date attributes
    - [x]  Not Needed
- [x]  Merge queries
    - [x]  Not Needed
- [x]  Append queries where appropriate
    - [x]  Not Needed
- [x]  Create a clean analytical table
    - [x]  Not Needed

### Important

For every transformation, record:

```
Problem found
        ↓
Transformation applied
        ↓
Reason
        ↓
Expected effect
```

Problem:- 

### Data Model(If Required)✅

- [x]  Power Query → Close and Load to → select only create connection check the box of create data model
- [x]  Create the Relationships between tables - STAR / SNOW FLAKS SCHEMA

### Data Analysis✅

- [x]  What is the monthly recurring revenue (MRR) from active paid subscriptions?
- [x]  Which plans generate the most revenue?
- [x]  How is revenue distributed across countries?
- [x]  Are there unusually high or negative subscription prices?
- [x]  How many subscriptions are active, paused, and cancelled?
- [x]  What is the cancellation rate for a defined period?
- [x]  How long do customers typically remain subscribed?
- [x]  Which plans or markets show higher cancellation rates?
- [x]  How many active customers are in each country?
- [x]  What is the average subscription price by plan and country?
- [x]  Which markets have the highest cancellation proportions?
- [x]  Are some countries more dependent on free subscriptions?
- [x]  How many records contain invalid or suspicious values?
- [x]  Which records violate the expected subscription lifecycle?
- [ ]  Are duplicate IDs genuine duplicate transactions or separate billing events?
- [ ]  How much could the identified data-quality problems affect reported revenue and churn?

### Visual Report structure to follow

#### **Page 1 — Executive Overview**

Management question: How is the subscription business performing?

- Active paid subscriptions
- MRR and average revenue per paid subscription
- Active, paused, and cancelled subscription counts
- Revenue by plan and country
- Reporting period and data-quality warning indicators

Decision: Determine which business areas require management attention.

#### Page 2 — Revenue and Plan Performance

Management question: Where does recurring revenue come from?

- MRR by month, if historical records support it
- Revenue contribution by plan
- Average paid subscription price
- Revenue by country
- Pricing anomalies and outlier details

Decision: Identify pricing and revenue segments for further investigation.

#### Page 3 — Customer Retention and Churn

Management question: Where are customers leaving the business?

- Cancellation counts and rates by period
- Subscription tenure distribution
- Cancellation rates by plan and country
- New versus cancelled subscriptions over time
- Cohort retention, if the available data supports it

Decision: Identify segments for retention research and possible intervention tests.

#### Page 4 — Market and Customer Segmentation

Management question: How does subscription performance differ between markets?

- Customer counts by normalized country
- Paid versus free subscription mix
- Revenue by market
- Cancellation rates by market
- Plan adoption across countries

Decision: Identify markets where localized research or marketing experiments may be useful.

#### Page 5 — Data Quality and Validation

Management question: Can we trust the numbers in the report?

- Duplicate subscription and customer records
- Invalid and missing fields
- Price anomalies
- Subscription lifecycle inconsistencies
- Reconciliation of raw versus cleaned metrics

Decision: Prioritize data remediation and decide which metrics are safe to use.
