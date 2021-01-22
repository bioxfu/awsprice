#' An Shiny addin for searching AWS EC2 price
#'
#' @export
#' @import shiny
#' @import shinycssloaders
#' @import miniUI
#' @import stringi
awsprice <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniPage(
    gadgetTitleBar("AWS Pricing (EC2)"),
    miniContentPanel(
      sidebarLayout(
        sidebarPanel(
          uiOutput("CPU_Controls"),
          uiOutput("RAM_Controls"),
          uiOutput("Type_Controls"),
          uiOutput("Region_Controls")
        ),

        mainPanel(
          withSpinner(DT::dataTableOutput('table'), type = 5)
        )
      )
    )
  )

  server <- function(input, output, session) {

    tb <- reactive({
      fetch_price_table()
    })

    output$CPU_Controls <- renderUI({
      n <- c(0, sort(as.numeric(unique(tb()$vCPUs))))
      cpu_n <- as.list(n)
      names(cpu_n) <- n
      selectInput("cpu", label = 'Choose CPU',
                  choices = cpu_n)
    })

    output$RAM_Controls <- renderUI({
      n <- c(0, sort(as.numeric(unique(tb()$Memory))))
      ram_n <- as.list(n)
      names(ram_n) <- n
      selectInput("ram", label = 'Choose Memory (GB)',
                  choices = ram_n)
    })
    # stringi::stri_escape_unicode("全部")
    output$Type_Controls <- renderUI({
      n <- c(stri_unescape_unicode('\\u5168\\u90e8'), unique(tb()$Type_cn))
      type_n <- as.list(n)
      names(type_n) <- n
      selectInput("type", label = 'Choose Type',
                  choices = type_n)
    })

    output$Region_Controls <- renderUI({
      n <- c(stri_unescape_unicode('\\u5168\\u90e8'), unique(tb()$Region))
      region_n <- as.list(n)
      names(region_n) <- n
      selectInput("region", label = 'Choose Region',
                  choices = region_n)
    })

    output$table <- DT::renderDataTable({
      tbl <- tb()
      vCPUs <- Memory <- Type_cn <- Region <-  NULL
      if (input$cpu > 0) {
        tbl <- tbl %>% filter(vCPUs == input$cpu)
      }
      if (input$ram > 0) {
        tbl <- tbl %>% filter(Memory == input$ram)
      }
      if (input$type != stri_unescape_unicode('\\u5168\\u90e8')) {
        tbl <- tbl %>% filter(Type_cn == input$type)
      }
      if (input$region != stri_unescape_unicode('\\u5168\\u90e8')) {
        tbl <- tbl %>% filter(Region == input$region)
      }

      DT::datatable(tbl, options = list(scrollX = TRUE))
    })

    observeEvent(input$done, {
      stopApp()
    })
  }

  viewer <- dialogViewer('AWS Pricing (EC2)', width = 1000, height = 600)
  runGadget(ui, server, viewer = viewer)

}

