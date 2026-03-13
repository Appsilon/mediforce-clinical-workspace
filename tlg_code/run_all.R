# ============================================================
# Master TLG Generation Script
# Study: CDISCPILOT01
# Generated: 2026-03-13
# ============================================================

cat("========================================\n")
cat("TLG Generation Master Script\n")
cat("Study: CDISCPILOT01\n")
cat("Date:", format(Sys.Date(), "%Y-%m-%d"), "\n")
cat("========================================\n\n")

# ---- Configuration ----
code_dir <- "/workspace/tlg_code"
output_dir <- "/workspace/tlg_outputs"
log_file <- file.path(output_dir, "tlg_generation_log.txt")

# Create log file
sink(log_file, append = FALSE, split = TRUE)

# ---- Define TLG scripts ----
tlg_scripts <- c(
  # Tables
  "t_01_disp.R",      # T-14.1.1 Subject Disposition
  "t_02_demo.R",      # T-14.1.2 Demographics
  "t_03_adascog_w24.R", # T-14.2.1 ADAS-Cog Week 24
  "t_04_ae_summ.R",   # T-14.3.1.1 AE Summary
  
  # Figures
  "f_01_km_ae.R",     # F-15.2.1 Time to First AE
  
  # Listings
  "l_01_ae_listing.R" # L-16.3.4 AE Listing
)

# Sort scripts
tlg_scripts <- sort(tlg_scripts)

# ---- Run TLG scripts ----
results <- list()
start_time <- Sys.time()

cat("Starting TLG generation...\n")
cat("Total scripts:", length(tlg_scripts), "\n\n")

for (i in seq_along(tlg_scripts)) {
  script <- tlg_scripts[i]
  script_path <- file.path(code_dir, script)
  
  cat("========================================\n")
  cat("Running:", script, "\n")
  cat("Time:", format(Sys.time(), "%H:%M:%S"), "\n")
  
  result <- tryCatch({
    # Source the script
    source(script_path, local = new.env())
    cat("  Status: SUCCESS\n")
    "OK"
  }, error = function(e) {
    cat("  Status: FAILED\n")
    cat("  Error:", e$message, "\n")
    paste("ERROR:", e$message)
  })
  
  results[[script]] <- result
  cat("\n")
}

end_time <- Sys.time()
duration <- difftime(end_time, start_time, units = "secs")

# ---- Summary ----
cat("========================================\n")
cat("TLG Generation Summary\n")
cat("========================================\n\n")

cat("Total scripts:", length(results), "\n")
cat("Successful:", sum(results == "OK"), "\n")
cat("Failed:", sum(results != "OK"), "\n")
cat("Duration:", round(duration, 1), "seconds\n\n")

# List failed scripts
failed <- names(results)[results != "OK"]
if (length(failed) > 0) {
  cat("Failed scripts:\n")
  for (f in failed) {
    cat("  -", f, ":", results[[f]], "\n")
  }
  cat("\n")
}

# Check output files
cat("Output files generated:\n")

# Tables
table_files <- list.files(file.path(output_dir, "tables"), pattern = "\\.html$", full.names = TRUE)
cat("  Tables:", length(table_files), "files\n")
if (length(table_files) > 0) {
  for (f in table_files) {
    file_size <- file.info(f)$size
    cat("    -", basename(f), sprintf("(%s KB)\n", round(file_size/1024, 1)))
  }
}

# Figures
figure_files <- list.files(file.path(output_dir, "figures"), pattern = "\\.(png|jpg|pdf)$", full.names = TRUE)
cat("  Figures:", length(figure_files), "files\n")
if (length(figure_files) > 0) {
  for (f in figure_files) {
    file_size <- file.info(f)$size
    cat("    -", basename(f), sprintf("(%s KB)\n", round(file_size/1024, 1)))
  }
}

# Listings
listing_files <- list.files(file.path(output_dir, "listings"), pattern = "\\.(html|csv)$", full.names = TRUE)
cat("  Listings:", length(listing_files), "files\n")
if (length(listing_files) > 0) {
  for (f in listing_files) {
    file_size <- file.info(f)$size
    cat("    -", basename(f), sprintf("(%s KB)\n", round(file_size/1024, 1)))
  }
}

# Close log file
sink()

cat("\n========================================\n")
cat("Generation complete.\n")
cat("Log file:", log_file, "\n")
cat("Output directory:", output_dir, "\n")
cat("========================================\n")