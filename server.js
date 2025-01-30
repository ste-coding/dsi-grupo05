const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Endpoint para buscar lugares no Foursquare
app.get('/search-places', async (req, res) => {
    try {
        const query = req.query.query || '';  // O que o usuário está buscando (e.g. "coffee")
        const ll = req.query.ll || '40.730610,-73.935242';  // Coordenadas de exemplo (pode ser latitude,longitude)
        const radius = req.query.radius || 5000;  // 5 km de raio, por exemplo

        // Configurando a URL da API do Foursquare
        const url = `https://api.foursquare.com/v3/places/search?query=${query}&ll=${ll}&radius=${radius}`;

        const response = await axios.get(url, {
        headers: {
            Authorization: `Bearer ${process.env.FSQ_API_KEY}`,
        },
        });

        res.json(response.data);
    } catch (error) {
        console.error('Erro ao fazer requisição:', error);
        res.status(500).send('Erro ao fazer requisição ao Foursquare');
    }
});

app.listen(port, () => {
    console.log(`Servidor rodando na porta ${port}`);
});