# Explore 14C profiles in ISRaD #
# Relationship between 14C and depth/SOC #
# Sophie von Fromm #
# 01/06/2022 #

library(ISRaD)
library(tidyverse)
library(ggpubr)

#Load filtered lyr data
lyr_data <- readRDS(paste0(getwd(), "/Data/ISRaD_lyr_data_filtered_", Sys.Date()))

lyr_data %>% 
  count(entry_name)

names(lyr_data)

## Mapping sampling locations ##
library("rnaturalearth")
library("rnaturalearthdata")
library(sf)

world <- map_data("world") %>% 
  filter(region != "Antarctica")

ggplot() +
  geom_map(
    data = world, map = world,
    aes(long, lat, map_id = region),
    color = "white", fill = "lightgrey")  +
  geom_point(data = lyr_data, 
             aes(x = pro_long, y = pro_lat),
             color = "#4D36C6", shape = 1, size = 3) +
  theme_bw(base_size = 14) +
  theme(rect = element_blank(),
        panel.grid = element_blank(),
        axis.ticks = element_line(color = "black"),
        axis.text = element_text(color = "black"),
        axis.line = element_line(color = "black")) +
  scale_x_continuous("", labels = c("100°W", "0", "100°E"), 
                     breaks = c(-100,0,100), limits = c(-160,180)) +
  scale_y_continuous("",labels = c("50°S", "0", "50°N"), 
                     breaks = c(-50,0,50), limits = c(-55,80))

## Data exploration ##

#lyr_14c
plotly::ggplotly(
  lyr_data %>% 
    ggplot(aes(x = depth, y = lyr_14c, group = entry_name)) + 
    geom_point(size = 3, shape = 21) +
    theme_bw(base_size = 16) +
    theme(axis.text = element_text(color = "black")) +
    scale_x_continuous("Depth [cm]", expand = c(0.01,0.01)) +
    scale_y_continuous(limits = c(-1505,305)) 
)

#lyr_dd14c
plotly::ggplotly(
  lyr_data %>% 
    ggplot(aes(x = depth, y = lyr_dd14c, group = entry_name)) + 
    geom_point(size = 3, shape = 21) +
    theme_bw(base_size = 16) +
    theme(axis.text = element_text(color = "black")) +
    scale_x_continuous("Depth [cm]", expand = c(0.01,0.01)) +
    scale_y_continuous(limits = c(-1505,305)) 
)

# Density distribution
p1 <- lyr_data %>% 
  ggplot(aes(x = CORG, y = lyr_14c)) + 
  geom_hex(color = NA, binwidth = c(0.1,50)) +
  theme_bw(base_size = 16) +
  theme(axis.text = element_text(color = "black")) +
  scale_x_continuous("SOC [wt-%]", trans = "log10") +
  scale_y_continuous(limits = c(-1505,305)) +
  scale_fill_viridis_c(trans = "log10")

p2 <- lyr_data %>% 
  ggplot(aes(x = CORG, y = lyr_dd14c)) + 
  geom_hex(color = NA, binwidth = c(0.1,50)) +
  theme_bw(base_size = 16) +
  theme(axis.text = element_text(color = "black")) +
  scale_x_continuous("SOC [wt-%]", trans = "log10") +
  scale_y_continuous(limits = c(-1505,305)) +
  scale_fill_viridis_c(trans = "log10")

ggarrange(p1, p2, common.legend = TRUE)

# Colored by sampling year
p1 <- lyr_data %>% 
  mutate(sampl_yr = cut(lyr_obs_date_y,
                        breaks = c(1899,1960,1984,1995,1999,2009,2012,2018))) %>% 
  ggplot(aes(y = depth, x = lyr_14c,
             fill = sampl_yr)) + 
  geom_point(aes(group = entry_name),
             size = 5, alpha = 0.8, shape = 21) +
  theme_bw(base_size = 16) +
  theme(axis.text = element_text(color = "black")) +
  scale_y_reverse("Depth [cm]", expand = c(0.01,0.01)) +
  scale_x_continuous(limits = c(-1505,305)) +
  scale_fill_viridis_d()

p2 <- lyr_data %>% 
  mutate(sampl_yr = cut(lyr_obs_date_y,
                        breaks = c(1899,1960,1984,1995,1999,2009,2012,2022))) %>% 
  ggplot(aes(y = depth, x = lyr_dd14c,
             fill = sampl_yr)) + 
  geom_point(aes(group = entry_name),
             size = 5, alpha = 0.8, shape = 21) +
  theme_bw(base_size = 16) +
  theme(axis.text = element_text(color = "black")) +
  scale_y_reverse("Depth [cm]", expand = c(0.01,0.01)) +
  scale_x_continuous(limits = c(-1505,305)) +
  scale_fill_viridis_d()

ggarrange(p1, p2, common.legend = TRUE)

lyr_data %>% 
  ggplot(aes(x = depth, y = CORG, z = lyr_14c)) + 
  stat_summary_hex(color = NA, binwidth = c(5,0.1),
                   fun = ~median(.x)) +
  theme_bw(base_size = 16) +
  theme(axis.text = element_text(color = "black")) +
  scale_x_continuous("Depth [cm]") +
  scale_y_continuous("SOC [wt-%]", trans = "log10") +
  scale_fill_viridis_c("Delta14C", limits = c(-1005,250),
                       option = "A") +
  guides(fill = guide_colorbar(barheight = 10, frame.colour = "black", 
                               ticks.linewidth = 2))

lyr_data %>% 
  ggplot(aes(y = lyr_14c, x = CORG, color = pro_BIO12_mmyr_WC2.1)) +
  geom_point(size = 5) +
  theme_bw(base_size = 16) +
  theme(axis.text = element_text(color = "black")) +
  scale_x_continuous("SOC [wt-%]", trans = "log10") +
  scale_color_viridis_c("MAP [mm]", trans = "log10")

lyr_data %>% 
  ggplot(aes(y = lyr_14c, x = CORG, color = pro_BIO1_C_WC2.1)) +
  geom_point(size = 5) +
  theme_bw(base_size = 16) +
  theme(axis.text = element_text(color = "black")) +
  scale_x_continuous("SOC [wt-%]", trans = "log10") +
  scale_color_viridis_c("MAT [C]")

summary(lyr_data$pro_BIO12_mmyr_WC2.1)

lyr_data %>% 
  count(pro_KG_present) %>% 
  view()

lyr_data %>% 
  filter(pro_KG_present == 0) %>% 
  count(entry_name)

lyr_data_KG <- lyr_data %>% 
  mutate(pro_KG_present_reclas = case_when(
    pro_KG_present == 1 ~ "Tropical, rainforest",
    pro_KG_present == 2 ~ "Tropical, monsoon",
    pro_KG_present == 3 ~ "Tropical, savannah",
    pro_KG_present == 5 ~ "Arid, desert, cold",
    pro_KG_present == 6 ~ "Arid, steppe, hot",
    pro_KG_present == 7 ~ "Arid, steppe, cold",
    pro_KG_present == 8 ~ "Temperate, dry summer, hot summer",
    pro_KG_present == 9 ~ "Temperate, dry summer, warm summer",
    pro_KG_present == 11 ~ "Temperate, dry winter, hot summer",
    pro_KG_present == 12 ~ "Temperate, dry winter, warm summer",
    pro_KG_present == 14 ~ "Temperate, no dry season, hot summer",
    pro_KG_present == 15 ~ "Temperate, no dry season, warm summer",
    pro_KG_present == 18 ~ "Cold, dry summer, warm summer",
    pro_KG_present == 19 ~ "Cold, dry summer, cold summer",
    pro_KG_present == 22 ~ "Cold, dry winter, warm summer",
    pro_KG_present == 23 ~ "Cold, dry winter, cold summer",
    pro_KG_present == 25 ~ "Cold, no dry season, hot summer",
    pro_KG_present == 26 ~ "Cold, no dry season, warm summer",
    pro_KG_present == 27 ~ "Cold, no dry season, cold summer",
    pro_KG_present == 29 ~ "Polar, tundra",
    #one study has no climate zone; assign manually
    pro_KG_present == 0 ~ "Polar, tundra"
  ))

lyr_data_KG %>% 
  filter(is.na(pro_KG_present_reclas)) %>% 
  count(entry_name)

lyr_data_KG %>% 
  filter(depth <= 200) %>% 
  ggplot(aes(x = depth, y = lyr_14c, fill = pro_BIO12_mmyr_WC2.1)) + 
  geom_point(shape = 21, size = 4, alpha = 0.7) +
  facet_wrap(~pro_KG_present_reclas) +
  theme_bw(base_size = 12) +
  theme(axis.text = element_text(color = "black"),
        panel.grid.minor = element_blank(),
        strip.background = element_rect(fill =  NA)) +
  scale_x_continuous("Depth [cm]") +
  scale_y_continuous("Delat14C") +
  scale_fill_viridis_c("MAP [mm]", trans = "log10") +
  guides(fill = guide_colorbar(barheight = 10, frame.colour = "black", 
                               ticks.linewidth = 2))

lyr_data_KG %>% 
  ggplot(aes(x = CORG, y = lyr_14c, fill = pro_BIO12_mmyr_WC2.1)) + 
  geom_point(shape = 21, size = 4, alpha = 0.7) +
  facet_wrap(~pro_KG_present_reclas) +
  theme_bw(base_size = 12) +
  theme(axis.text = element_text(color = "black"),
        panel.grid.minor = element_blank(),
        strip.background = element_rect(fill =  NA)) +
  scale_x_continuous("SOC", trans = "log10") +
  scale_y_continuous("Delat14C") +
  scale_fill_viridis_c("MAP [mm]", trans = "log10") +
  guides(fill = guide_colorbar(barheight = 10, frame.colour = "black", 
                               ticks.linewidth = 2))

lyr_data_soil <- lyr_data_KG %>% 
  mutate(pro_usda_soil_order = case_when(
    pro_usda_soil_order == 150 ~ "Gelisols",
    pro_usda_soil_order == 151 ~ "Histosols",
    pro_usda_soil_order == 152 ~ "Spodosols",
    pro_usda_soil_order == 153 ~ "Andisols",
    pro_usda_soil_order == 154 ~ "Oxisols",
    pro_usda_soil_order == 155 ~ "Vertisols",
    pro_usda_soil_order == 156 ~ "Aridisols",
    pro_usda_soil_order == 157 ~ "Ultisols",
    pro_usda_soil_order == 158 ~ "Mollisols",
    pro_usda_soil_order == 159 ~ "Alfisols",
    pro_usda_soil_order == 160 ~ "Inceptisols",
    pro_usda_soil_order == 161 ~ "Entisols",
    TRUE ~ pro_usda_soil_order
  ))

lyr_data_soil %>% 
  filter(is.na(pro_usda_soil_order)) %>% 
  count(entry_name)

lyr_data_soil %>% 
  drop_na(pro_usda_soil_order) %>% 
  filter(depth <= 200) %>% 
  ggplot(aes(x = depth, y = lyr_14c, fill = pro_BIO12_mmyr_WC2.1)) + 
  geom_point(shape = 21, size = 4, alpha = 0.7) +
  facet_wrap(~pro_usda_soil_order) +
  theme_bw(base_size = 12) +
  theme(axis.text = element_text(color = "black"),
        panel.grid.minor = element_blank(),
        strip.background = element_rect(fill =  NA)) +
  scale_x_continuous("Depth [cm]") +
  scale_y_continuous("Delat14C") +
  scale_fill_viridis_c("MAP [mm]", trans = "log10") +
  guides(fill = guide_colorbar(barheight = 10, frame.colour = "black", 
                               ticks.linewidth = 2))

lyr_data_soil %>% 
  drop_na(pro_usda_soil_order) %>% 
  ggplot(aes(x = CORG, y = lyr_14c, fill = pro_BIO12_mmyr_WC2.1)) + 
  geom_point(shape = 21, size = 4, alpha = 0.7) +
  facet_wrap(~pro_usda_soil_order) +
  theme_bw(base_size = 12) +
  theme(axis.text = element_text(color = "black"),
        panel.grid.minor = element_blank(),
        strip.background = element_rect(fill =  NA)) +
  scale_x_continuous("SOC", trans = "log10") +
  scale_y_continuous("Delat14C") +
  scale_fill_viridis_c("MAP [mm]", trans = "log10") +
  guides(fill = guide_colorbar(barheight = 10, frame.colour = "black", 
                               ticks.linewidth = 2))
