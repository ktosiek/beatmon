#!/usr/bin/env node

const express = require("express");
const { postgraphile } = require("postgraphile");

const app = express();
const env = app.get('env');

app.use(postgraphile(process.env.DATABASE_URL || "socket:/var/run/postgresql?db=beatmon", 'beatmon', {
    watchPg: env == 'development',
    pgDefaultRole: 'beatmon/anon',
    ignoreRBAC: false,
    jwtSecret: 'Secret',  // TODO: change for production
    jwtPgTypeIdentifier: 'beatmon.jwt_token',
    showErrorStack: env == 'development',
    extendedError: ['hint', 'detail', 'errcode'],  // TODO: proper error handling for production
    appendPlugins: [require('@graphile-contrib/pg-simplify-inflector')],
    graphiql: env == 'development',
    enhanceGraphiql: env == 'development',
}));

app.listen(process.env.PORT || 5000);
