package it.beat.entity;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigInteger;
import java.sql.Date;
@Entity
@Table(name = "eventi")
@ToString
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor


public class Eventi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_evento")
    private BigInteger idEvento;

    @Column(name = "titolo", nullable = false, length = 100 )
    private String titolo;

    @Column(name ="descrizione", nullable = true)
    private String descrizione;

    @Column(name ="protagonista", nullable = false, length = 100)
    private String protagonista;

    @Column(name = "immagine_url", nullable = false, length = 255)
    private String immagineUrl;







}
