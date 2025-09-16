# ----Libraries----
library(shiny)
library(shinydashboard)
library(DT)

# ----Front-end----
ui <- dashboardPage(
  skin = "black",
  
  # ----HEADER----
  dashboardHeader(title = "Two Carhops Simulation"),
  
  # ----SIDEBAR----
  dashboardSidebar(
    sliderInput(inputId = "n_customer",
                label = "Jumlah Customer:",
                min = 5,
                max = 100,
                value = 20),
    
    sliderInput(inputId = "seed_value",
                label = "Randomness Seed:",
                min = 1,
                max = 100,
                value = 42),
    
    hr(),
    
    tags$h4("Parameter Simulasi", style = "padding-left: 15px;"),
    
    tags$b("Waktu Antar Kedatangan:", style = "padding-left: 15px;"),
    tags$p("1 mnt: 25%, 2 mnt: 40%, 3 mnt: 20%, 4 mnt: 15%", style = "padding-left: 15px; font-size: 90%;"),
    
    tags$b("Waktu Layanan Ali:", style = "padding-left: 15px;"),
    tags$p("2 mnt: 30%, 3 mnt: 28%, 4 mnt: 25%, 5 mnt: 17%", style = "padding-left: 15px; font-size: 90%;"),
    
    tags$b("Waktu Layanan Badu:", style = "padding-left: 15px;"),
    tags$p("3 mnt: 35%, 4 mnt: 25%, 5 mnt: 20%, 6 mnt: 20%", style = "padding-left: 15px; font-size: 90%;")
    
  ),
  
  # ----BODY----
  dashboardBody(
    # ----Baris untuk menampilkan Metrik-metrik (Value Boxes)----
    fluidRow(
      # Kolom untuk Skenario 1: Pilihan Acak
      column(width = 4,
             tags$h3("Skenario Pilihan Acak", align = "center"),
             valueBoxOutput(outputId = "avg_wait_random", width = NULL),
             valueBoxOutput(outputId = "max_wait_random", width = NULL),
             valueBoxOutput(outputId = "served_ali_random", width = NULL),
             valueBoxOutput(outputId = "served_badu_random", width = NULL),
             valueBoxOutput(outputId = "idle_ali_random", width = NULL),
             valueBoxOutput(outputId = "idle_badu_random", width = NULL)
      ),
      # Kolom untuk Skenario 2: Prioritas Ali
      column(width = 4,
             tags$h3("Skenario Prioritas Ali", align = "center"),
             valueBoxOutput(outputId = "avg_wait_to_ali", width = NULL),
             valueBoxOutput(outputId = "max_wait_to_ali", width = NULL),
             valueBoxOutput(outputId = "served_ali_to_ali", width = NULL),
             valueBoxOutput(outputId = "served_badu_to_ali", width = NULL),
             valueBoxOutput(outputId = "idle_ali_to_ali", width = NULL),
             valueBoxOutput(outputId = "idle_badu_to_ali", width = NULL)
      ),
      # Kolom untuk Skenario 3: Prioritas Badu
      column(width = 4,
             tags$h3("Skenario Prioritas Badu", align = "center"),
             valueBoxOutput(outputId = "avg_wait_to_badu", width = NULL),
             valueBoxOutput(outputId = "max_wait_to_badu", width = NULL),
             valueBoxOutput(outputId = "served_ali_to_badu", width = NULL),
             valueBoxOutput(outputId = "served_badu_to_badu", width = NULL),
             valueBoxOutput(outputId = "idle_ali_to_badu", width = NULL),
             valueBoxOutput(outputId = "idle_badu_to_badu", width = NULL)
      )
    ),
    
    # ----Baris untuk menampilkan Tabel Hasil Simulasi----
    fluidRow(
      box(
        title = "Skenario 1: Pilih Acak",
        width = 12,
        solidHeader = TRUE, status = "primary",
        dataTableOutput("table_random")
      ),
      box(
        title = "Skenario 2: Prioritas ke Ali",
        width = 12,
        solidHeader = TRUE, status = "warning",
        dataTableOutput("table_to_ali")
      ),
      box(
        title = "Skenario 3: Prioritas ke Badu",
        width = 12,
        solidHeader = TRUE, status = "info",
        dataTableOutput("table_to_badu")
      )
    )
  )
)

# ----Back-end----
server <- function(input, output) {
  
  # Fungsi bantuan untuk memformat waktu dari desimal ke "X menit Y detik"
  format_waktu <- function(waktu_desimal) {
    menit <- floor(waktu_desimal)
    detik <- round((waktu_desimal - menit) * 60)
    
    if (menit > 0 && detik > 0) {
      return(paste(menit, "menit", detik, "detik"))
    } else if (menit > 0 && detik == 0) {
      return(paste(menit, "menit"))
    } else if (menit == 0 && detik > 0) {
      return(paste(detik, "detik"))
    } else {
      return("0 detik")
    }
  }
  
  # ----FUNGSI INTI SIMULASI----
  # Menambahkan argumen 'seed' ke dalam fungsi
  run_simulation <- function(n, idle_choice_rule, seed) {
    set.seed(seed) # Menggunakan seed dari input slider
    
    probs_interarrival <- c(0.25, 0.40, 0.20, 0.15)
    probs_ali <- c(0.30, 0.28, 0.25, 0.17); times_ali <- c(2,3,4,5)
    probs_badu <- c(0.35, 0.25, 0.20, 0.20); times_badu <- c(3,4,5,6)
    
    interarrival <- sample(1:4, n, replace = TRUE, prob = probs_interarrival)
    arrival_time <- cumsum(interarrival)
    
    next_free <- c(0,0); last_finish <- c(0,0); busy_time <- c(0,0); idle_time_srv <- c(0,0)
    customer_ke <- 1:n; assigned_server <- character(n); start_service_time <- integer(n)
    service_duration <- integer(n); finish_time <- integer(n)
    
    for (i in 1:n) {
      t_arr <- arrival_time[i]
      free_now <- which(next_free <= t_arr)
      
      if (length(free_now) > 0) {
        if (all(c(1,2) %in% free_now)) {
          if (idle_choice_rule == "random") {
            server <- sample(c(1,2), 1)
          } else if (idle_choice_rule == "ali") {
            server <- 1
          } else {
            server <- 2
          }
        } else {
          server <- free_now[1]
        }
        start <- t_arr
      } else {
        server <- which.min(next_free)
        start <- next_free[server]
      }
      
      idle_time_srv[server] <- idle_time_srv[server] + max(0, start - last_finish[server])
      
      sd <- if (server == 1) sample(times_ali, 1, prob = probs_ali) else sample(times_badu, 1, prob = probs_badu)
      
      finish <- start + sd
      assigned_server[i] <- ifelse(server == 1, "Ali", "Badu")
      start_service_time[i] <- start
      service_duration[i] <- sd
      finish_time[i] <- finish
      busy_time[server] <- busy_time[server] + sd
      last_finish[server] <- finish
      next_free[server] <- finish
    }
    
    waiting_time <- start_service_time - arrival_time
    time_in_system <- finish_time - arrival_time
    
    antrian <- data.frame(
      Pelanggan = customer_ke,
      Waktu_Kedatangan = arrival_time,
      Server = assigned_server,
      Waktu_Mulai_Dilayani = start_service_time,
      Durasi_Pelayanan = service_duration,
      Waktu_Selesai_Layanan = finish_time,
      Durasi_Tunggu_Dilayani = waiting_time,
      Waktu_di_Sistem = time_in_system
    )
    
    max_wait <- if (length(waiting_time) > 0) max(waiting_time) else 0
    n_served_ali <- sum(assigned_server == "Ali")
    n_served_badu <- sum(assigned_server == "Badu")
    
    return(list(
      table = antrian,
      stats = list(
        avg_wait = round(mean(waiting_time), 2),
        max_wait = round(max_wait, 2),
        n_served_ali = n_served_ali,
        n_served_badu = n_served_badu,
        idle_ali = idle_time_srv[1],
        idle_badu = idle_time_srv[2]
      )
    ))
  }
  
  # ----REACTIVE EXPRESSIONS----
  sim_random <- reactive({ run_simulation(input$n_customer, "random", input$seed_value) })
  sim_to_ali <- reactive({ run_simulation(input$n_customer, "ali", input$seed_value) })
  sim_to_badu <- reactive({ run_simulation(input$n_customer, "badu", input$seed_value) })
  
  
  # ----RENDER OUTPUTS: SCENARIO RANDOM----
  output$avg_wait_random <- renderValueBox({ 
    valueBox(format_waktu(sim_random()$stats$avg_wait), "Rata-rata Durasi Menunggu Dilayani", icon = icon("clock"), color = "light-blue") 
  })
  output$max_wait_random <- renderValueBox({ 
    valueBox(format_waktu(sim_random()$stats$max_wait), "Durasi Menunggu Dilayani Terlama", icon = icon("clock"), color = "light-blue") 
  })
  output$served_ali_random <- renderValueBox({ 
    valueBox(sim_random()$stats$n_served_ali, "Total Pelanggan Dilayani Ali", icon = icon("user-check"), color = "light-blue") 
  })
  output$served_badu_random <- renderValueBox({ 
    valueBox(sim_random()$stats$n_served_badu, "Total Pelanggan Dilayani Badu", icon = icon("user-check"), color = "light-blue") 
  })
  output$idle_ali_random <- renderValueBox({ 
    valueBox(format_waktu(sim_random()$stats$idle_ali), "Durasi Idle Ali", icon = icon("pause-circle"), color = "light-blue") 
  })
  output$idle_badu_random <- renderValueBox({ 
    valueBox(format_waktu(sim_random()$stats$idle_badu), "Durasi Idle Badu", icon = icon("pause-circle"), color = "light-blue") 
  })
  
  # ----RENDER OUTPUTS: SCENARIO ALI PRIORITY----
  output$avg_wait_to_ali <- renderValueBox({ 
    valueBox(format_waktu(sim_to_ali()$stats$avg_wait), "Rata-rata Durasi Menunggu Dilayani", icon = icon("clock"), color = "orange") 
  })
  output$max_wait_to_ali <- renderValueBox({ 
    valueBox(format_waktu(sim_to_ali()$stats$max_wait), "Durasi Menunggu Dilayani Terlama", icon = icon("clock"), color = "orange") 
  })
  output$served_ali_to_ali <- renderValueBox({ 
    valueBox(sim_to_ali()$stats$n_served_ali, "Total Pelanggan Dilayani Ali", icon = icon("user-check"), color = "orange") 
  })
  output$served_badu_to_ali <- renderValueBox({ 
    valueBox(sim_to_ali()$stats$n_served_badu, "Total Pelanggan Dilayani Badu", icon = icon("user-check"), color = "orange") 
  })
  output$idle_ali_to_ali <- renderValueBox({ 
    valueBox(format_waktu(sim_to_ali()$stats$idle_ali), "Durasi Idle Ali", icon = icon("pause-circle"), color = "orange") 
  })
  output$idle_badu_to_ali <- renderValueBox({ 
    valueBox(format_waktu(sim_to_ali()$stats$idle_badu), "Durasi Idle Badu", icon = icon("pause-circle"), color = "orange") 
  })
  
  # ----RENDER OUTPUTS: SCENARIO BADU PRIORITY----
  output$avg_wait_to_badu <- renderValueBox({ 
    valueBox(format_waktu(sim_to_badu()$stats$avg_wait), "Rata-rata Durasi Menunggu Dilayani", icon = icon("clock"), color = "teal") 
  })
  output$max_wait_to_badu <- renderValueBox({ 
    valueBox(format_waktu(sim_to_badu()$stats$max_wait), "Durasi Menunggu Dilayani Terlama", icon = icon("clock"), color = "teal") 
  })
  output$served_ali_to_badu <- renderValueBox({ 
    valueBox(sim_to_badu()$stats$n_served_ali, "Total Pelanggan Dilayani Ali", icon = icon("user-check"), color = "teal") 
  })
  output$served_badu_to_badu <- renderValueBox({ 
    valueBox(sim_to_badu()$stats$n_served_badu, "Total Pelanggan Dilayani Badu", icon = icon("user-check"), color = "teal") 
  })
  output$idle_ali_to_badu <- renderValueBox({ 
    valueBox(format_waktu(sim_to_badu()$stats$idle_ali), "Durasi Idle Ali", icon = icon("pause-circle"), color = "teal") 
  })
  output$idle_badu_to_badu <- renderValueBox({ 
    valueBox(format_waktu(sim_to_badu()$stats$idle_badu), "Durasi Idle Badu", icon = icon("pause-circle"), color = "teal") 
  })
  
  # ----Render Data Tables----
  output$table_random <- renderDataTable({
    datatable(
      data = sim_random()$table,
      options = list(scrollX = TRUE, scrollY = FALSE)
    )
  })
  output$table_to_ali <- renderDataTable({
    datatable(
      data = sim_to_ali()$table,
      options = list(scrollX = TRUE, scrollY = FALSE)
    )
  })
  output$table_to_badu <- renderDataTable({
    datatable(
      data = sim_to_badu()$table,
      options = list(scrollX = TRUE, scrollY = FALSE)
    )
  })
}

# ----Start the App----
shinyApp(ui = ui, server = server)

