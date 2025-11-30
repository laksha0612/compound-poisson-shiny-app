library(shiny)
library(ggplot2)

# Function to simulate a single path of the compound Poisson process S(t)
simulate_cpp_path <- function(lambda, mu, T_max) {
  # 1. Simulate arrival times (jumps)
  interarrivals <- rexp(n = 5000, rate = lambda)
  arrival_times <- cumsum(interarrivals)
  
  # Filter arrivals within T_max
  arrival_times <- arrival_times[arrival_times <= T_max]
  N_t <- length(arrival_times)
  
  # 2. Simulate claim sizes
  if (N_t > 0) {
    X_i_values <- rexp(N_t, rate = mu)
    S_t_path <- cumsum(X_i_values)
  } else {
    S_t_path <- 0
  }
  
  # 3. Create step function data frame for plotting
  
  # Time points: 0, and then two points for each arrival (start and end of jump)
  plot_times <- c(0, rep(arrival_times, each = 2), T_max)
  
  # S(t) values: 0, then hold, then jump
  plot_S_t <- c(0, 0)
  for (i in 1:N_t) {
    # S(t) holds the previous value until the new arrival time
    prev_S_t <- ifelse(i == 1, 0, S_t_path[i-1])
    plot_S_t <- c(plot_S_t, prev_S_t)
    # S(t) jumps to the new value at the arrival time
    plot_S_t <- c(plot_S_t, S_t_path[i])
  }
  
  # Ensure the final point is the last S_t value at T_max
  final_S_t <- tail(plot_S_t, 1)
  plot_S_t <- c(plot_S_t, final_S_t)
  
  # Trim to match length
  # This construction ensures plot_times and plot_S_t have the same length (2*N_t + 2)
  # The last S_t value in the vector should be the actual final value of the process
  plot_S_t <- plot_S_t[1:length(plot_times)]
  
  return(data.frame(Time = plot_times, S_t = plot_S_t))
}

# Function to simulate many values for the final distribution (histogram)
simulate_cpp_final_values <- function(lambda, mu, T_max, N_simulations) {
  S_T_values <- replicate(N_simulations, {
    N_t <- rpois(1, lambda * T_max)
    S_t <- ifelse(N_t > 0, sum(rexp(N_t, rate = mu)), 0)
    return(S_t)
  })
  return(S_T_values)
}

# --- SHINY UI ---
ui <- fluidPage(
  titlePanel("Compound Poisson Process Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Process Parameters"),
      sliderInput("lambda", "Poisson Arrival Rate (λ):", 
                  min = 0.1, max = 5, value = 2, step = 0.1),
      sliderInput("mu", "Claim Size Rate (μ):", 
                  min = 0.1, max = 2, value = 0.5, step = 0.05),
      sliderInput("T_max", "Max Time (T):", 
                  min = 10, max = 50, value = 20, step = 1),
      numericInput("N_simulations", "No. of Simulations for Histogram:", 
                   value = 5000, min = 1000, step = 1000),
      actionButton("resimulate", "Resimulate Path & Distribution", class = "btn-primary"),
      
      hr(),
      p(strong("E[S(T)] = λT/μ:")),
      textOutput("expected_value"),
      p(strong("Var[S(T)] = 2λT/μ²:")),
      textOutput("variance_value")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Process Path S(t) vs Time", 
                 plotOutput("path_plot")),
        tabPanel("Final Distribution Histogram", 
                 plotOutput("hist_plot"))
      )
    )
  )
)

# --- SHINY SERVER ---
server <- function(input, output) {
  
  # Store simulated data (only recalculates when Resimulate is pressed)
  sim_data <- eventReactive(input$resimulate, {
    lambda <- isolate(input$lambda)
    mu <- isolate(input$mu)
    T_max <- isolate(input$T_max)
    N_sim <- isolate(input$N_simulations)
    
    path <- simulate_cpp_path(lambda, mu, T_max)
    final_values <- simulate_cpp_final_values(lambda, mu, T_max, N_sim)
    
    list(path = path, final_values = final_values)
  }, ignoreNULL = FALSE) 
  
  # Process Path Plot
  output$path_plot <- renderPlot({
    data <- sim_data()$path
    
    ggplot(data, aes(x = Time, y = S_t)) +
      geom_line(color = "darkgreen", size = 1.2) +
      labs(title = paste("Simulated Path of S(t) | λ=", input$lambda, ", μ=", input$mu),
           x = "Time (t)", 
           y = "Compound Process Value (S(t))") +
      theme_minimal() 
  })
  
  # Histogram Plot
  output$hist_plot <- renderPlot({
    values <- sim_data()$final_values
    expected_S_t <- (input$lambda * input$T_max) / input$mu
    
    ggplot(data.frame(S_t = values), aes(x = S_t)) +
      geom_histogram(aes(y = after_stat(density)), bins = 50, fill = "lightblue", color = "white") +
      geom_vline(xintercept = expected_S_t, linetype = "dashed", color = "red", size = 1) +
      labs(title = paste("Distribution of S(t) at T = ", input$T_max),
           subtitle = paste("Theoretical Mean (red line):", round(expected_S_t, 2)),
           x = "S(T)", 
           y = "Density") +
      theme_minimal()
  })
  
  # Expected Value Output
  output$expected_value <- renderText({
    expected_S_t <- (input$lambda * input$T_max) / input$mu
    paste0(round(expected_S_t, 2))
  })
  
  # Variance Value Output
  output$variance_value <- renderText({
    variance_S_t <- (input$lambda * input$T_max * 2) / (input$mu)^2
    paste0(round(variance_S_t, 2))
  })
}
shinyApp(ui = ui, server = server)
