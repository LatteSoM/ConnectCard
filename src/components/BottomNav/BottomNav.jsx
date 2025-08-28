import React, { useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { BottomNavigation, BottomNavigationAction, Paper, Box } from "@mui/material";
import { motion, AnimatePresence } from "framer-motion";
import { Home, Person, BarChart, CreditCard } from "@mui/icons-material";

const navItems = [
  { label: "Главная", icon: <Home />, path: "/profile" },
  { label: "Визитки", icon: <CreditCard />, path: "/list_of_visit_cards" },
  { label: "Контакты", icon: <Person />, path: "/contacts" },
  { label: "Статистика", icon: <BarChart />, path: "/stat" },
];

const BottomNav = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [value, setValue] = useState(location.pathname);

  const handleChange = (_, newValue) => {
    setValue(newValue);
    navigate(newValue);
  };

  return (
    <Paper
      sx={{
        position: "fixed",
        bottom: 0,
        left: 0,
        right: 0,
        bgcolor: "#000",
      }}
      elevation={8}
    >
      <BottomNavigation
        value={value}
        onChange={handleChange}
        showLabels={false} // отключаем стандартные подписи
        sx={{ bgcolor: "#000" }}
      >
        {navItems.map((item) => (
          <BottomNavigationAction
            key={item.path}
            value={item.path}
            icon={
              <Box sx={{ display: "flex", alignItems: "center", gap: "6px" }}>
                {item.icon}
                <AnimatePresence>
                  {value === item.path && (
                    <motion.span
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -10 }}
                      transition={{ duration: 0.2 }}
                      style={{ fontSize: "14px", color: "#E040FB" }}
                    >
                      {item.label}
                    </motion.span>
                  )}
                </AnimatePresence>
              </Box>
            }
            sx={{
              color: value === item.path ? "#E040FB" : "white",
              minWidth: "60px",
            }}
          />
        ))}
      </BottomNavigation>
    </Paper>
  );
};

export default BottomNav;
