#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
require(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)
theme_set(theme_bw())
library(rsconnect)
library(data.table)
#library(tidyverse)
#deployApp()


mydata <- read.csv("share-of-adults-defined-as-obese.csv",header = TRUE)
mydata2 <- read.csv("share-of-deaths-obesity.csv",header = TRUE)
total <- merge(mydata,mydata2,by=c("Entity","Code","Year"))

##Section 1 ____________________________________________________
# Define UI for application that draws a histogram
ui = shinyUI(
  dashboardPage(
    skin = "purple",
    dashboardHeader(title="Global Status of Obesity",titleWidth = 350),
    dashboardSidebar(
      sidebarMenu(
        #create tab sidebar
        menuItem("About", tabName= "info", icon=icon("user"), badgeLabel = "Our App",badgeColor = "aqua"),
        menuItem("Obesity Checker", tabName= "dashboard", icon=icon("calculator"),badgeLabel = "BMI Base",badgeColor = "fuchsia"),
        #menuItem("Top 10", tabName= "Top 10", icon=icon("arrow-up"), badgeLabel = "Our App",badgeColor = "aqua"),
        menuItem("Obesity %", tabName="dataset", icon=icon("bar-chart-o"),badgeLabel = "Graph",badgeColor = "orange"),
        menuItem("Deaths %", tabName="dataset2", icon=icon("bar-chart-o"),badgeLabel = "Graph",badgeColor = "red"),
        menuItem("Obesity vs Deaths %", tabName="correlation", icon=icon("bar-chart-o"),badgeLabel = "plot",badgeColor = "maroon"),
        menuItem("Source Code", icon=icon("code"),href = "https://github.com/Nurzahirah/WIE2003-Group-Project-",newtab=F,badgeLabel = "Github",badgeColor = "lime")
      )
    ),
    dashboardBody(
      #this application is about 
      tabItems(
        tabItem(tabName = "info",
                h3("About Data Product"),   
                fluidPage(
                p("1. Our data product is an app called 'Global Status of Obesity',which emphasizes on obesity rate and death by obesity rate that are based on countries from 1975 until 2016."),
                p("2. This app contains four main tab aside from this tab named as obesity checker based on BMI, obesity % and death % tab that consist of plot and graph based on each dataset, and lastly source code tab that will link to github for this app source code."),
                p("3. Obese dataset contains all countries around the world that have obesity problems, while death dataset consist of countries that have a death case results from obesity."),
                p("4. Both datasets are obtained from https://ourworldindata.org/obesity"),
                box(width = 9,
                    title=strong("Group Memeber"), solidHeader = TRUE,collapsible=TRUE,status = "success",
                    img(src= "Group.png" ,width = "650", height = "450")
                )
                )
        ),
        #Tab content
        #BMI
        tabItem(tabName = "dashboard",
                h1("BMI calculator"),
                box(
                  title=strong("Input info"), solidHeader = TRUE,collapsible=TRUE,status = "info" ,
                  numericInput(inputId = "weight", label = 
                                 "Enter your weight (kilogram,kg)", value = 50, min = 1, max=300, step=1),
                  numericInput(inputId = "height", label = 
                                 "Enter your height (metre,m)", value = 1.64, min = 1, max=500, step=2),
                ),
                box(
                  title=strong("Results"), solidHeader = TRUE,collapsible=TRUE,status = "info" ,
                  h3('Your BMI is:'),
                  h4('Weight:'),
                  verbatimTextOutput("weigh"),
                  h4('Height:'),
                  verbatimTextOutput("heigh"),
                  h4('BMI and Category:'),
                  verbatimTextOutput("bmi"),
                )
        ),
        
       # tabItem(tabName = "Top 10",
        #        h1("Top 10 Countries"),
         #       box (
          #        title = "Top 10", solidHeader = TRUE, collapsible=TRUE, status="warning",
           #       #inner part of result
            #      h4(strong("Countries with the highest mean of obesity")),
             #     plotOutput("top10")
              #  )
        #),
        
        #second tab
        tabItem(tabName = "dataset",
                h1("Worldwide Obesity"),
                
                box(
                  title=strong("Input Tab"), solidHeader = TRUE,collapsible=TRUE,status = "primary" ,
                  h4(strong("Choose country to visualise the data")),
                  selectInput("country","Select the Country: ",choices = as.character(unique(mydata$Entity)), selected = "Malaysia"),
                  #htmlOutput("country_selector")
                  #h5(strong("Top 10 countries with highest mean of obesity rate")),
                  #tableOutput("top10")
                  
                ),
                box (
                  title = "Bar Chart", solidHeader = TRUE,collapsible=TRUE,status="primary",
                  #inner part of result
                  h4(strong("Year versus Obesity Rate")),
                  plotOutput("bchart")
                ),
                box(
                  title=strong("Top 10"), solidHeader = TRUE,collapsible=TRUE,status = "primary" ,
                  h5(strong("Top 10 countries with highest mean of obesity rate")),
                  tableOutput("top10")
                ),
                fluidPage(
                  box(
                    title = "Box Plot", solidHeader = TRUE,collapsible=TRUE,status="primary",
                    br(),
                    h2("BoxPlot of The Whole Dataset from All Country"),
                    p("This visualisation gives us a bigger picture on global status of obesity"),
                    br(),
                    plotOutput("myplot"),
                    downloadButton("downloadData","Download Data")
                ))
        ),
        #third tab
        tabItem(tabName = "dataset2",
                h1("Worldwide Deaths caused by Obesity"),
                box(
                  title=strong("Input Tab"), solidHeader = TRUE,collapsible=TRUE,status = "primary" ,
                  h4(strong("Choose country to visualise the data")),
                  selectInput("country2","Select the Country: ",choices = as.character(unique(mydata2$Entity)), selected = "Malaysia")
                  #htmlOutput("country_selector")
                ),
                
                box (
                  title = "Bar Chart", solidHeader = TRUE, collapsible=TRUE, status="primary",
                  #inner part of result
                  h4(strong("Year versus Deaths Rate")),
                  plotOutput("bchart2")
                ),               
                
                fluidPage(
                  h2("BoxPlot of The Whole Dataset from All Country"),
                  p("This visualisation gives us a bigger picture on global status of deaths caused by obesity"),
                  br(),
                  plotOutput("myplot2"),
                  downloadButton("downloadData2","Download Data")
                )
        ),
        #forth tab
        tabItem(tabName = "correlation",
                h1("Correlation between the Percentage of Deaths and Obesity"),
                box(
                  title=strong("Input Tab"), solidHeader = TRUE,collapsible=TRUE,status = "primary" ,
                  h4(strong("Choose country to visualise the data")),
                  selectInput("country3","Select the Country: ",choices = as.character(unique(total$Entity)), selected = "Malaysia")
                  #htmlOutput("country_selector")
                ),
                box (
                  title = "Scatter Plot", solidHeader = TRUE, collapsible=TRUE, status="primary",
                  #inner part of result
                  h4(strong("Obesity rate versus Deaths rate")),
                  plotOutput("bchart3")
                ), 
                
                fluidPage(
                  h2("ScatterPlot of The Whole Dataset from All Country"),
                  p("This visualisation gives us a bigger picture on global status of correlation between obesity and deaths"),
                  br(),
                  plotOutput("correlation"),
                  downloadButton("downloadData3","Download Data")
                )
        )
        #tabItems    
      )
      #dashboardBody
    )
    
    #dashboardPage    
  )
  #shinyUI
)

##Section 2 ____________________________________________________
# Define server logic required to draw a histogram
server= shinyServer(function(input, output,session) {
  
  output$weigh <- renderText(input$weight)
  output$heigh <- renderText(input$height)
  output$bmi <- renderText({BMI(input$weight,input$height)})
  
  BMI <- function(weigh,heigh){
    BMI <- weigh / (heigh*heigh)
    if(BMI<18.5) return(paste(BMI,"Underweight"))
    else if (BMI<25) return(paste(BMI,"Normal weight"))
    else if (BMI<30) return(paste(BMI,"Overweight"))
    else if (BMI<35) return(paste(BMI,"Obesity I"))
    else if (BMI<40) return(paste(BMI,"Obesity II"))
    else if (BMI>=40) return(paste(BMI,"Obesity III"))
  }
  
  #output$country_selector <- renderUI({
  #    selectInput(inputId = "country",label = "Country: ",choices = as.character(unique(mydata$Entity)))
  #})
  
  
  #SECOND TAB
  output$bchart <- renderPlot({
    filtered <-
      mydata %>% filter(Entity== input$country) %>% 
      arrange((Year))
    ggplot(filtered, aes(x=Year,y=Share.of.adults.who.are.obese....))+
      geom_bar(stat="identity",fill="maroon")+
      scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"))+
      labs(x="Year",y="Obese Rate(%)")
  })
  
  #download
  output$downloadData <- downloadHandler(
    filename = function(){
      paste("Obesity","csv",sep=".")
    },
    content = function(file){
      write.csv(mydata,file)
    }
  )
  
  output$top10<- renderTable({
    adult <- data.table(mydata)
    allMean <- adult[,mean(Share.of.adults.who.are.obese....),by=Entity]
    allMean %>% slice_max(V1, n = 10)
  })
    
  output$myplot <- renderPlot({
    boxplot(mydata$Share.of.adults.who.are.obese....~mydata$Year,
            xlab = "Year",ylab = "Percentage of obese adult worldwide(%)",
            main = "Graph of Percentage of obese adult worldwide against Year",
            col = "blue", las = 1)
  })
  
  
  #THIRD TAB
  output$bchart2 <- renderPlot({
    filtered2 <-
      mydata2 %>% filter(Entity== input$country2) %>% 
      arrange((Year))
    ggplot(filtered2, aes(x=Year,y=Share.of.deaths.from.obesity....))+
      geom_bar(stat="identity",fill="maroon")+
      scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"))+
      labs(x="Year",y="Deaths Rate (%)")
  })
  #download 
  output$downloadData2 <- downloadHandler(
    filename = function(){
      paste("Deaths caused by obesity","csv",sep=".")
    },
    content = function(file){
      write.csv(mydata2,file)
    }
  )
  output$myplot2 <- renderPlot({
    boxplot(mydata2$Share.of.deaths.from.obesity....~mydata2$Year,
            xlab = "Year",ylab = "Percentage of deaths caused by obesity worldwide (%)",
            main = "Graph of Percentage of deaths caused by obese worldwide against Year",
            col = "blue", las = 1)
  })
  
  
  #FORTH TAB
  ##download
  output$downloadData3 <- downloadHandler(
    filename = function(){
      paste("Correlation","png",sep=".")
    },
    content = function(file){
      png(file)
      filtered3 <- total %>% filter(Entity== input$country3) 
      ggplot(filtered3, aes(x=Share.of.adults.who.are.obese....,y=Share.of.deaths.from.obesity....))+
        labs(x="Percentage of Obesity (%)",y="Percentage of deaths caused by obesiy (%)")+geom_point(color="blue")
      dev.off()
    }
  )
  
  output$bchart3 <- renderPlot({
    filtered3 <- total %>% filter(Entity== input$country3) 
    ggplot(filtered3, aes(x=Share.of.adults.who.are.obese....,y=Share.of.deaths.from.obesity....))+
      labs(x="Percentage of Obesity (%)",y="Percentage of deaths caused by obesiy (%)")+geom_point(size=2,color="blue")
    
  })
  
  output$correlation <- renderPlot({
    plot(total$Share.of.adults.who.are.obese....,total$Share.of.deaths.from.obesity....,
         xlab = "Percentage of Obesity (%)",ylab = "Percentage of Deaths (%)",
         main = "Graph of Percentage of Obesity against Deaths Worldwide",
         col = "blue", las = 1)
  })
  
  #shinyserver
})

##Section 3____________________________________________________
shinyApp(ui = ui, server = server)
