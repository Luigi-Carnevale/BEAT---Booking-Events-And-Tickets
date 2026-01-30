package com.beat.coreLogic;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public class Evento {
    private int id;
    private String titolo;
    private String descrizione;
    private LocalDate data;
    private LocalTime ora;
    private String luogo;
    private int postiTotali;
    private int postiDisponibili;
    private BigDecimal prezzo;
    private String categoria;
    private boolean gratuito;


}