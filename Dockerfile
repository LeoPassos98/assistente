# ---- Estágio 1: Builder ----
# Define a imagem base do Node.js para o estágio de build
FROM node:20-alpine AS builder

# Define o diretório de trabalho dentro do container
WORKDIR /usr/src/app

# Copia os arquivos de definição de pacotes
# Garanta que package-lock.json existe e está versionado para 'npm ci'
COPY package*.json ./

# Instala todas as dependências de forma limpa e consistente
RUN npm ci

# Copia todos os arquivos do projeto para o diretório de trabalho
# O .dockerignore garantirá que arquivos desnecessários não sejam copiados
COPY . .

# Executa o script de build (geralmente 'nest build')
RUN npm run build

# ---- Estágio 2: Production ----
# Define uma imagem base do Node.js mais leve para produção
FROM node:20-alpine

# Define o diretório de trabalho
WORKDIR /usr/src/app

# Copia os arquivos de definição de pacotes novamente
COPY package*.json ./

# Instala APENAS as dependências de produção
RUN npm ci --only=production

# Copia os artefatos construídos (a pasta 'dist') do estágio 'builder'
COPY --from=builder /usr/src/app/dist ./dist

# Expõe a porta que sua aplicação NestJS usa (padrão é 3000)
EXPOSE 3000

# Comando para iniciar a aplicação quando o container rodar
CMD ["node", "dist/main.js"]