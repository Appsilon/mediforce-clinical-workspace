# ============================================================
# TLG ID: F-15.2.1
# Title: Time to First Treatment-Emergent Adverse Event
# Population: Safety Analysis Set
# Source: ADAE
# Method: Kaplan-Meier survival analysis
# ============================================================

source("/workspace/tlg_code/00_setup.R")

cat("Generating F-15.2.1: Time to First Treatment-Emergent Adverse Event...\n")

# ---- Read data ----
adae <- read_adam("ADAE")
adsl <- read_adam("ADSL")

# ---- Filter population ----
safety_pop <- adsl %>% filter(SAFFL == "Y") %>% pull(USUBJID)

# Get first TEAE for each subject
first_ae <- adae %>%
  filter(
    USUBJID %in% safety_pop,
    TRTEMFL == "Y"
  ) %>%
  group_by(USUBJID) %>%
  summarise(
    time_to_first_ae = min(ASTDY, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(
    adsl %>% select(USUBJID, TRT01P),
    by = "USUBJID"
  )

# Create analysis dataset with censoring
analysis_data <- adsl %>%
  filter(SAFFL == "Y") %>%
  select(USUBJID, TRT01P, EOSDY) %>%
  left_join(first_ae, by = c("USUBJID", "TRT01P")) %>%
  mutate(
    time = ifelse(is.na(time_to_first_ae), EOSDY, time_to_first_ae),
    event = ifelse(is.na(time_to_first_ae), 0, 1)
  ) %>%
  filter(!is.na(time) & time >= 0)

# ---- Kaplan-Meier analysis ----
km_result <- run_km(
  data = analysis_data,
  time_var = "time",
  event_var = "event",
  trt_var = "TRT01P"
)

# Extract survival data for plotting
surv_data <- survfit(Surv(time, event) ~ TRT01P, data = analysis_data)
surv_summary <- summary(surv_data)

# Prepare data for ggplot
plot_data <- data.frame(
  time = surv_summary$time,
  surv = surv_summary$surv,
  strata = surv_summary$strata,
  n.risk = surv_summary$n.risk,
  n.event = surv_summary$n.event,
  n.censor = surv_summary$n.censor
) %>%
  mutate(
    treatment = gsub("TRT01P=", "", strata)
  )

# ---- Create Kaplan-Meier plot ----
p <- ggplot(plot_data, aes(x = time, y = surv, color = treatment)) +
  geom_step(linewidth = 1) +
  scale_color_manual(
    values = c("Placebo" = "#1f77b4", 
               "Xanomeline low dose" = "#ff7f0e", 
               "Xanomeline high dose" = "#2ca02c")
  ) +
  labs(
    title = "Time to First Treatment-Emergent Adverse Event",
    subtitle = "Population: Safety Analysis Set — Study CDISCPILOT01",
    x = "Time (Days)",
    y = "Proportion Event-Free",
    color = "Treatment"
  ) +
  study_theme() +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2)) +
  scale_x_continuous(breaks = seq(0, max(plot_data$time, na.rm = TRUE), 30)) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

# Add number at risk table
# Create risk table data
risk_table_data <- plot_data %>%
  group_by(treatment) %>%
  summarise(
    time_points = list(seq(0, max(time), 30)),
    .groups = "drop"
  ) %>%
  unnest(time_points) %>%
  left_join(
    plot_data %>%
      group_by(treatment) %>%
      arrange(time) %>%
      mutate(
        next_time = lead(time),
        n_risk_at = n.risk
      ) %>%
      select(treatment, time, n_risk_at),
    by = c("treatment", "time_points" = "time")
  ) %>%
  group_by(treatment) %>%
  fill(n_risk_at, .direction = "down") %>%
  mutate(
    n_risk_at = ifelse(is.na(n_risk_at), 0, n_risk_at),
    label = paste0(treatment, "\nn=", n_risk_at)
  )

# Create risk table plot
risk_table <- ggplot(risk_table_data, aes(x = time_points, y = treatment, label = n_risk_at)) +
  geom_text(size = 3) +
  labs(x = "Time (Days)", y = "") +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(c(0, 0.5, 0.5, 0.5), "cm")
  )

# Combine plots (simplified version - in practice would use patchwork or cowplot)
# For now, save just the KM plot

# ---- Export ----
output_file <- file.path(output_dir, "figures", "f_01_km_ae.png")
ggsave(output_file, plot = p, width = 10, height = 7, dpi = 300)
cat("Saved to:", output_file, "\n")

# Also save survival data for reference
surv_output_file <- file.path(output_dir, "figures", "f_01_km_ae_data.csv")
write_csv(plot_data, surv_output_file)
cat("Survival data saved to:", surv_output_file, "\n")

cat("F-15.2.1 generation complete.\n")