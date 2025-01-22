<?php

namespace Mindverse\DifyClient;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;

class DifyClient
{
    protected $api_key;
    protected $base_url;
    protected $client;

    public function __construct($api_key, $base_url = null)
    {
        $this->api_key = $api_key;
        $this->base_url = $base_url ?? "https://api.dify.ai/v1/";
        $this->client = new Client([
            'base_uri' => $this->base_url,
            'headers' => [
                'Authorization' => 'Bearer ' . $this->api_key,
                'Content-Type' => 'application/json',
            ],
        ]);
    }

    /**
     * @throws GuzzleException
     */
    public function createCompletion($inputs, $query, $response_mode = 'blocking', $user = null)
    {
        $data = [
            'inputs' => $inputs,
            'query' => $query,
            'response_mode' => $response_mode,
        ];
        if ($user) {
            $data['user'] = $user;
        }

        $response = $this->client->post('completion-messages', [
            'json' => $data,
        ]);

        return json_decode($response->getBody()->getContents(), true);
    }

    /**
     * @throws GuzzleException
     */
    public function createChatCompletion($inputs, $query, $user = null, $response_mode = 'blocking', $conversation_id = null)
    {
        $data = [
            'inputs' => $inputs,
            'query' => $query,
            'response_mode' => $response_mode,
        ];
        if ($user) {
            $data['user'] = $user;
        }
        if ($conversation_id) {
            $data['conversation_id'] = $conversation_id;
        }

        $response = $this->client->post('chat-messages', [
            'json' => $data,
        ]);

        return json_decode($response->getBody()->getContents(), true);
    }

    /**
     * @throws GuzzleException
     */
    public function getMessageFeedback($message_id)
    {
        $response = $this->client->get("messages/{$message_id}/feedbacks");
        return json_decode($response->getBody()->getContents(), true);
    }

    /**
     * @throws GuzzleException
     */
    public function createMessageFeedback($message_id, $rating, $user = null)
    {
        $data = ['rating' => $rating];
        if ($user) {
            $data['user'] = $user;
        }

        $response = $this->client->post("messages/{$message_id}/feedbacks", [
            'json' => $data,
        ]);

        return json_decode($response->getBody()->getContents(), true);
    }

    /**
     * @throws GuzzleException
     */
    public function getConversationMessages($conversation_id, $user = null, $first_id = null, $limit = null)
    {
        $query = [];
        if ($user) {
            $query['user'] = $user;
        }
        if ($first_id) {
            $query['first_id'] = $first_id;
        }
        if ($limit) {
            $query['limit'] = $limit;
        }

        $response = $this->client->get("conversations/{$conversation_id}/messages", [
            'query' => $query,
        ]);

        return json_decode($response->getBody()->getContents(), true);
    }

    /**
     * @throws GuzzleException
     */
    public function getConversations($user = null, $first_id = null, $limit = null, $pinned = null)
    {
        $query = [];
        if ($user) {
            $query['user'] = $user;
        }
        if ($first_id) {
            $query['first_id'] = $first_id;
        }
        if ($limit) {
            $query['limit'] = $limit;
        }
        if ($pinned !== null) {
            $query['pinned'] = $pinned;
        }

        $response = $this->client->get('conversations', [
            'query' => $query,
        ]);

        return json_decode($response->getBody()->getContents(), true);
    }

    /**
     * @throws GuzzleException
     */
    public function renameConversation($conversation_id, $name, $user = null)
    {
        $data = ['name' => $name];
        if ($user) {
            $data['user'] = $user;
        }

        $response = $this->client->patch("conversations/{$conversation_id}", [
            'json' => $data,
        ]);

        return json_decode($response->getBody()->getContents(), true);
    }
}
